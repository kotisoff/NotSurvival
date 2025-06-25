local not_utils    = require "shared/utils/not_utils"
local mode         = not_utils.multiplayer.mode
local mp           = not_utils.multiplayer.api.server

local block_dest   = require "shared/lib/block_destruction"
local packets      = require "shared/utils/declarations/packets"
local resource     = require "shared/utils/resource_func"
local server_utils = require "server/lib/server_utils"

local pack_id      = "not_survival"

---@type {pos: vec3, id: int, progress: number, tick: int, wrap: int, stage: int, pid: int}[]
local breaking     = {}

-- =========================funcs===========================

local function start_breaking(pos, pid)
  local texture = block_dest.get_breaking_texture(0)
  local wrap_id = mp.blockwraps.wrap(pos, texture)

  local target = {
    pos = pos,
    id = block.get(unpack(pos)),
    progress = 0,
    wrap = wrap_id,
    texture = block_dest.get_breaking_texture(0),
    pid = pid
  }

  table.insert(breaking, target)
end

local function get_target(pid)
  for index, value in ipairs(breaking) do
    if value.pid == pid then
      return value, index
    end
  end
end

local function is_breaking(pid)
  return not not get_target(pid)
end

local function stop_breaking(pid)
  local _, index = get_target(pid)
  table.remove(breaking, index)
end


local function destruct(pid, target)
  local x, y, z = unpack(target.pos)
  block.destruct(x, y, z, pid)

  if mode ~= "standalone" then
    local sound = block.materials[block.material(target.id)].breakSound
    local sx, sy, sz = block_dest.get_block_center(target.pos)
    mp.audio.play_sound(sound, sx, sy, sz, 1, 1)
  end

  events.emit(resource("l:block_broken"), target.id, x, y, z, pid)
end

local function checkVector(vec)
  return vec and #vec == 3 and is_array(vec)
end

-- ========================network==========================

mp.events.on(pack_id, packets.block_breaking, function(client, bytes)
  local pid = client.player.pid
  local status, pos = pcall(mp.bson.deserialize, bytes)

  if status and checkVector(pos) then
    start_breaking(pos, pid)
  elseif is_breaking(pid) then
    local target = get_target(pid)
    if block_dest.get_durability(target.id) == 0 then
      destruct(pid, target)
    end

    stop_breaking(pid)
  end
end)

-- ================server=breaking=handler==================

events.on(resource("player_tick"), function(pid, default_tps)
  if not is_breaking(pid) then return end
  local target = get_target(pid)

  local tps = server_utils.tps
  local speed = block_dest.get_breaking_speed(pid, target.id)

  target.progress = target.progress + (1 / tps) * speed

  if target.progress >= 1 then
    destruct(pid, target)
    stop_breaking(pid)
    return
  end

  local texture = block_dest.get_breaking_texture(target.progress)
  if target.stage ~= texture then
    mp.blockwraps.set_texture(target.wrap, texture)
  end
end)

-- ======================block=drop=========================
local drop_utils = require "shared/utils/drop_utils"
local base_utils = require "base:util"

events.on(resource("l:block_broken"), function(blockid, x, y, z, pid)
  local ns_drop = drop_utils.block_loot(blockid)

  ---@type { items: {item: int,count:int,vel:vec3}[] }
  local drop = {
    items = base_utils.block_loot(blockid),
    experience = ns_drop.experience
  }

  -- Prepare center pos for drop
  local pos = vec3.add({ x, y, z }, 0.5)

  -- Validate drop
  for _, loot in ipairs(drop.items) do
    if loot.item then
      ---@type voxelcore.class.entity
      local entity = base_utils.drop(pos, loot.item, loot.count)

      if mode == "standalone" then
        local vel = vec3.spherical_rand(3)
        entity.rigidbody:set_vel(vel)
      end
    else
      debug.warning("Failed to get block drop id. Block: " .. block.name(blockid))
    end
  end

  ns_drop.callback(blockid, x, y, z, pid)
end)

-- =========================test============================
local health = require "server/lib/health"

events.on(resource("l:block_broken"), function(blockid, x, y, z, pid)
  -- health.damage(pid, 1, { source = vec3.sub({ player.get_pos(pid) }, { 0, 5, 0 }) })
end)
