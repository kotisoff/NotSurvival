local not_utils       = require "shared/utils/not_utils"
local mode            = not_utils.multiplayer.mode
local mp              = not_utils.multiplayer.api.client

local packets         = require "shared/utils/declarations/packets"
local resource        = require "shared/utils/resource_func"
local block_dest      = require "shared/lib/block_destruction"

local pack_id         = "not_survival"

---@class ns.breaking.target
---@field breaking bool
---@field pos vec3
---@field id int
---@field tick int
---@field progress number [0,1]
---@field wrap int
local target          = {
  breaking = false,
  pos = { 0, 0, 0 },
  id = 0,
  states = 0,
  tick = 0,
  progress = 0,
  wrap = 0
}

local breaking_states = block_dest.breaking_states

-- ========================network==========================
-- ниже пиздец

---@type { pos: vec3, id: int, pid: int, tick: int, progress: number, wrap: int }[]
local wraps           = {}

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

mp.events.on(pack_id, packets.block_breaking, function(bytes)
  ---@type [ ns.breaking.states, vec3, int, int, int | nil ]
  local args = mp.bson.deserialize(bytes)
  local state, pos, id, pid, states = unpack(args)

  if state == breaking_states.start then
    local wrap = gfx.blockwraps.wrap(pos, block_dest.get_breaking_texture(0))
    local element = {
      progress = 0,
      tick = 0,
      pos = pos,
      id = block.get(unpack(pos)),
      pid = pid,
      wrap = wrap
    }
    table.insert(wraps, element)
  elseif state == breaking_states.interrupted then
    if states and vec3.equals(target.pos, pos) then
      -- Сервер блять не доволен тем что ты насрал!
      -- Ну короче этот перец уже сломал свой блок, но слишком быстро, поэтому сервер сейчас отправит его нахуй.
      local x, y, z = unpack(pos)
      block.set(x, y, z, id, states)
    else
      remove_wrap(pos)
    end
  elseif state == breaking_states.broken then
    if not vec3.equals(target.pos, pos) then
      local x, y, z = unpack(pos)
      block.set(x, y, z, 0)
      local sound = block.materials[block.material(id)].breakSound
      audio.play_sound(sound, x, y, z, 1, 1)
      remove_wrap(pos)
    end
  end
end)

-- ================managing=all=that=shit===================

local function set_player_rules(pid)
  player.set_instant_destruction(pid, false)
  player.set_infinite_items(pid, false)
end

local destruction = {}

function destruction.start()
  target.wrap = gfx.blockwraps.wrap(target.pos, block_dest.get_breaking_texture(target.progress))
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
      local tx, ty, tz = unpack(target.pos)

      -- Interrupt if block is different from player is looking at
      if block.get(x, y, z) ~= target.id or
          x ~= tx or y ~= ty or z ~= tz then
        return destruction.interrupt()
      end

      -- Breaking progress
      local speed = block_dest.get_breaking_speed(pid, target.id)
      target.progress = target.progress + (1 / tps) * speed
      target.tick = target.tick + 1

      -- Perform breaking
      if target.progress >= 1 or block_dest.get_durability(target.id) == 0 then
        destruction.broken()
        return block.destruct(x, y, z, pid)
      end
    elseif x ~= nil then
      target.breaking = true
      target.pos = { x, y, z }
      target.id = block.get(x, y, z)
      target.states = block.get_states(x, y, z)
      target.tick = 0
      target.progress = 0

      destruction.start()
    end
  elseif target.breaking then
    destruction.interrupt()
  end
end

local function animate_breaking()
  gfx.blockwraps.set_texture(target.wrap, block_dest.get_breaking_texture(target.progress))

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
    local speed = block_dest.get_breaking_speed(wrap.pid, wrap.id)
    wrap.progress = wrap.progress + (1 / tps) * speed
    wrap.tick = wrap.tick + 1

    gfx.blockwraps.set_texture(wrap.wrap, block_dest.get_breaking_texture(wrap.progress))

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

events.on(resource("player_tick"), function(pid, tps)
  local playerid = hud.get_player()
  if pid ~= playerid then return end

  manage_breaking(pid, tps)
  if target.breaking then
    animate_breaking()
  end

  animate_all_wraps(tps)
end)
