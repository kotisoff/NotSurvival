local ns_events         = require "shared/core/ns_events";
local net_events        = require "shared/network/utils/net_events";
local destruction_utils = require "shared/utils/destruction_utils";
local bson              = require "shared/utils/bson";


local packets         = net_events.packets;
local breaking_states = destruction_utils.breaking_states


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

-- =========================funcs===========================

local function new_target(x, y, z)
  target = {
    breaking = true,
    pos = { x, y, z },
    id = block.get(x, y, z),
    states = block.get_states(x, y, z),
    tick = 0,
    progress = 0,
    wrap = target.wrap or 0
  }

  return target;
end

-- ===================destruction=funcs=====================

local destruction = {}

function destruction.start()
  target.wrap = gfx.blockwraps.wrap(target.pos, destruction_utils.get_breaking_texture(target.progress))
  net_events.client.send(packets.block_breaking, bson.serialize({ breaking_states.start, target.pos }))
end

function destruction.stop(state)
  gfx.blockwraps.unwrap(target.wrap)
  target.breaking = false

  net_events.client.send(packets.block_breaking, bson.serialize({ state, target.pos }))
end

function destruction.interrupt()
  destruction.stop(breaking_states.interrupted)
end

function destruction.broken()
  destruction.stop(breaking_states.broken)
end

-- =========================wraps===========================

local wraps = {};

---@type { pos: vec3, id: int, pid: int, tick: int, progress: number, wrap: int }[]
local wraps_store = {}

function wraps.get(pos)
  for index, value in ipairs(wraps_store) do
    if vec3.equals(pos, value.pos) then
      return value, index
    end
  end
end

function wraps.remove(pos)
  local el, index = wraps.get(pos)
  if index then
    gfx.blockwraps.unwrap(el.wrap)
    table.remove(wraps_store, index)
    return true
  end
  return false
end

function wraps.new(pos, pid)
  local wrap_id = gfx.blockwraps.wrap(pos, destruction_utils.get_breaking_texture(0));
  local wrap = {
    progress = 0,
    tick = 0,
    pos = pos,
    id = block.get(unpack(pos)),
    pid = pid,
    wrap = wrap_id
  }

  table.insert(wraps_store, wrap);

  return wrap;
end

-- =========================================================

---@param pid int
---@param tps number
local function manage_breaking(pid, tps)
  player.set_instant_destruction(pid, false);
  player.set_infinite_items(pid, false);

  -- Check button press
  if input.is_active("player.destroy") and not hud.is_inventory_open() and not hud.is_paused() then
    -- Get block player is looking at
    local x, y, z = player.get_selected_block(pid);

    -- If is already breaking
    if target.breaking then
      -- Interrupt if block is different from player is looking at
      if block.get(x, y, z) ~= target.id or not vec3.equals({ x, y, z }, target.pos) then
        destruction.interrupt();
        return
      end

      -- Breaking progress
      local speed = destruction_utils.get_breaking_speed(pid, target.id);
      target.progress = target.progress + (1 / tps) * speed;
      target.tick = target.tick + 1;

      -- Perform breaking
      if target.progress >= 1 then
        block.destruct(x, y, z, pid); -- вызывает ивент на клиенте
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
  for _, wrap in pairs(wraps_store) do
    local speed = destruction_utils.get_breaking_speed(wrap.pid, wrap.id)
    wrap.progress = wrap.progress + (1 / tps) * speed
    wrap.tick = wrap.tick + 1

    gfx.blockwraps.set_texture(wrap.wrap, destruction_utils.get_breaking_texture(wrap.progress))

    if wrap.progress >= 1 then
      wraps.remove(wrap.pos)
    end

    if wrap.tick % 4 == 0 then
      local x, y, z = unpack(wrap.pos)
      local sound = block.get_sound(wrap.id, "stepsSound");
      audio.play_sound(sound, x + 0.5, y + 0.5, z + 0.5, 1, 1)
    end
  end
end

ns_events.on("player_tick", function(pid, tps)
  local playerid = hud.get_player()
  if pid ~= playerid then return end

  manage_breaking(pid, tps)
  if target.breaking then
    animate_breaking()
  end

  animate_all_wraps(tps)
end)
