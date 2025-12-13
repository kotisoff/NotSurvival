local ns_events         = require "shared/core/ns_events";
local net_events        = require "shared/network/utils/net_events";
local mp                = require "shared/utils/not_utils".multiplayer
local destruction_utils = require "shared/utils/destruction_utils";


---@type neutron.shared.bson
local bson    = mp.as_any(function(side) return side.bson end);
local packets = net_events.packets;
local pack_id = require "constants".pack_id;


---@class ns.breaking.client_target
---@field breaking bool
---@field pos vec3
---@field id int
---@field tick int
---@field progress number [0,1]
---@field wrap int
local target = {
  breaking = false,
  pos = { 0, 0, 0 },
  id = 0,
  states = 0,
  tick = 0,
  progress = 0,
  wrap = 0
}


local breaking_states = destruction_utils.breaking_states

-- =========================wraps===========================


---@type { pos: vec3, id: int, pid: int, tick: int, progress: number, wrap: int }[]
wraps = {}

local function get_wrap(pos)
  for index, value in ipairs(wraps) do
    if vec3.equals(pos, value.pos) then
      return value, index
    end
  end
end

local function remove_wrap(pos)
  local el, index = get_wrap(pos)
  if index then
    gfx.blockwraps.unwrap(el.wrap)
    table.remove(wraps, index)
    return true
  end
  return false
end

-- ========================network==========================

---@type table<ns.breaking.states, fun(pos: vec3, blockid: int, pid: int, t_pid: int, block_state?: int)>
local handlers = {};

handlers[breaking_states.start] = function(pos, _, pid, t_pid)
  if pid == t_pid then
    return -- возможно подкорректировать некоторые моменты
  end

  local wrap_id = gfx.blockwraps.wrap(pos, destruction_utils.get_breaking_texture(0));
  local wrap = {
    progress = 0,
    tick = 0,
    pos = pos,
    id = block.get(unpack(pos)),
    pid = t_pid,
    wrap = wrap_id
  }

  table.insert(wraps, wrap);
end

handlers[breaking_states.interrupted] = function(pos, blockid, pid, t_pid, block_state)
  if block_state and vec3.equals(target.pos, pos) and pid == t_pid then
    local x, y, z = unpack(pos);
    block.set(x, y, z, blockid, block_state);
  else
    remove_wrap(pos);
  end
end

handlers[breaking_states.broken] = function(pos, blockid, pid, t_pid, block_state)
  if pid == t_pid then
    return -- если честно хз чё сюда писать
  end

  local x, y, z = unpack(pos);
  block.set(x, y, z, 0);
  local sound = block.get_sound(blockid, "breakSound");
  audio.play_sound(sound, x, y, z, 1, 1);
  remove_wrap(pos);
end

net_events.client.on(packets.block_breaking, function(bytes)
  ---@type [ ns.breaking.states, vec3, int, int, int | nil ]
  local args = bson.deserialize(bytes)
  local state, pos, blockid, t_pid, block_state = unpack(args)
  local pid = hud.get_player();

  handlers[state](pos, blockid, pid, t_pid, block_state);
end)

-- ================managing=all=that=shit===================

local function set_player_rules(pid)
  player.set_instant_destruction(pid, false)
  player.set_infinite_items(pid, false)
end

local destruction = {}

function destruction.start()
  target.wrap = gfx.blockwraps.wrap(target.pos, destruction_utils.get_breaking_texture(target.progress))
  mp.events.send(pack_id, packets.block_breaking, mp.bson.serialize({ breaking_states.start, target.pos }))
end

function destruction.stop(state)
  gfx.blockwraps.unwrap(target.wrap)
  target.breaking = false
  mp.events.send(pack_id, packets.block_breaking, mp.bson.serialize({ state, target.pos }))
end

function destruction.interrupt()
  destruction.stop(breaking_states.interrupted)
end

function destruction.broken()
  destruction.stop(breaking_states.broken)
end

---@param pid int
---@param tps number
local function manage_breaking(pid, tps)
  set_player_rules(pid)

  -- Check button press
  if input.is_active("player.destroy") and not hud.is_inventory_open() and not hud.is_paused() then
    -- Get block player is looking at
    local x, y, z = player.get_selected_block(pid)

    -- If is already breaking
    if target.breaking then
      -- Interrupt if block is different from player is looking at
      if block.get(x, y, z) ~= target.id or not vec3.equals({ x, y, z }, target.pos) then
        destruction.interrupt()
        return
      end

      -- Breaking progress
      local speed = destruction_utils.get_breaking_speed(pid, target.id)
      target.progress = target.progress + (1 / tps) * speed
      target.tick = target.tick + 1

      -- Perform breaking
      if target.progress >= 1 then
        destruction.broken()
        block.destruct(x, y, z, pid)
        return
      end
    elseif x ~= nil then
      target.breaking = true
      target.pos = { x, y, z }
      target.id = block.get(x, y, z)
      target.states = block.get_states(x, y, z)
      target.tick = 0
      target.progress = 0

      destruction.start()

      if destruction_utils.get_durability(target.id) == 0 then
        destruction.broken();
        block.destruct(x, y, z, pid);
      end
    end
  elseif target.breaking then
    destruction.interrupt()
  end
end

local function animate_breaking()
  gfx.blockwraps.set_texture(target.wrap, destruction_utils.get_breaking_texture(target.progress))

  if target.tick % 4 == 0 then
    local x, y, z = unpack(target.pos)
    local sound = block.materials[block.material(target.id)].stepsSound
    audio.play_sound(sound, x + 0.5, y + 0.5, z + 0.5, 1, 1)

    local camera = cameras.get("core:first-person")
    local ray = block.raycast(camera:get_pos(), camera:get_front(), 64.0)
    if not ray then return end

    gfx.particles.emit(ray.endpoint, 4, {
      lifetime = 1.0,
      spawn_interval = 0.0001,
      explosion = { 3, 3, 3 },
      velocity = vec3.add(vec3.mul(camera:get_front(), -1.0), { 0, 0.5, 0 }),
      texture = "blocks:" .. block.get_textures(target.id)[1],
      random_sub_uv = 0.1,
      size = { 0.1, 0.1, 0.1 },
      size_spread = 0.2,
      spawn_shape = "box",
      collision = true
    })
  end
end

local function animate_all_wraps(tps)
  for _, wrap in pairs(wraps) do
    local speed = destruction_utils.get_breaking_speed(wrap.pid, wrap.id)
    wrap.progress = wrap.progress + (1 / tps) * speed
    wrap.tick = wrap.tick + 1

    gfx.blockwraps.set_texture(wrap.wrap, destruction_utils.get_breaking_texture(wrap.progress))

    if wrap.progress >= 1 then
      remove_wrap(wrap.pos)
    end

    if wrap.tick % 4 == 0 then
      local x, y, z = unpack(wrap.pos)
      local sound = block.materials[block.material(wrap.id)].stepsSound
      audio.play_sound(sound, x + 0.5, y + 0.5, z + 0.5, 1, 1)
    end
  end
end

ns_events.on(("player_tick"), function(pid, tps)
  local playerid = hud.get_player()
  if pid ~= playerid then return end

  manage_breaking(pid, tps)
  if target.breaking then
    animate_breaking()
  end

  animate_all_wraps(tps)
end)
