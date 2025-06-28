local not_utils       = require "shared/utils/not_utils"
local mode            = not_utils.multiplayer.mode
local mp              = not_utils.multiplayer.api.server

local block_dest      = require "shared/lib/block_destruction"
local packets         = require "shared/utils/declarations/packets"
local resource        = require "shared/utils/resource_func"
local server_utils    = require "server/lib/util/server_utils"

local pack_id         = "not_survival"

local breaking_states = block_dest.breaking_states

---@type {pos: vec3, id: int, start: number}[][]
local breaking        = {}

-- =========================funcs===========================

local function vec_equals(veca, vecb)
  if #veca ~= #vecb then return false end

  for index, value in ipairs(veca) do
    if value ~= vecb[index] then
      return false
    end
  end

  return true
end

local function get_target(pid, pos)
  for index, value in ipairs(breaking[pid]) do
    if vec_equals(pos, value.pos) then
      return value, index
    end
  end
end

-- ========================network==========================

---@param state ns.breaking.states
---@param target {pos: vec3, id: int, start: number}
---@param ignore_client neutron.class.client | nil
local function echo_state(state, target, ignore_client)
  local pos = target.pos
  local players = mp.sandbox.players.get_in_radius({ x = pos[1], y = pos[2], z = pos[3] }, 50)
  for name, _player in pairs(players) do
    if ignore_client and name == ignore_client.player.username then return end
    local _client = mp.accounts.get_client_by_name(name)

    mp.events.tell(pack_id, packets.block_breaking, _client, mp.bson.serialize({ state, pos, target.id }))
  end
end

mp.events.on(pack_id, packets.block_breaking, function(client, bytes)
  local pid        = client.player.pid
  ---@type [ ns.breaking.states, vec3 ]
  local args       = mp.bson.deserialize(bytes)
  local state, pos = unpack(args)

  if state == breaking_states.start then
    breaking[pid] = breaking[pid] or {}
    local target = { pos = pos, id = block.get(unpack(pos)), start = time.uptime() }
    table.insert(breaking[pid], target)

    echo_state(breaking_states.start, target, client)
  elseif state == breaking_states.interrupted then
    local target, index = get_target(pid, pos)

    if target then
      echo_state(breaking_states.interrupted, target, client)
      table.remove(breaking[pid], index)
    end
  elseif state == breaking_states.broken then
    local target, index = get_target(pid, pos)
    local id = block.get(unpack(pos))

    if not target or id ~= target.id then return end

    local durability = block_dest.get_durability(target.id)
    if durability > 0 then
      local _end = time.uptime()
      local total = _end - target.start
      local expected_time = durability / block_dest.get_speed_multiplier(pid)
      local deviation = 0.5

      if (expected_time - deviation) >= total then
        mp.events.tell(pack_id, packets.block_breaking, client,
          mp.bson.serialize({ breaking_states.interrupted, pos, target.id, block.get_states(unpack(target.pos)) }))
      end
    end

    echo_state(breaking_states.broken, target, nil)

    local x, y, z = unpack(target.pos)
    events.emit(resource("l:block_broken"), target.id, x, y, z, pid)

    table.remove(breaking[pid], index)
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
