local ns_events         = require "shared/core/ns_events"
local net_events        = require "shared/network/utils/net_events";
local mp                = require "shared/utils/not_utils".multiplayer;
local destruction_utils = require "shared/utils/destruction_utils"

local api               = mp.api.server;
local bson              = api.bson;
local packets           = net_events.packets;
local breaking_states   = destruction_utils.breaking_states
local pack_id           = require "constants".pack_id;


---@type {pos: vec3, id: int, pid: int, start: number}[][]
local breaking = {}

-- =========================funcs===========================

local function get_target(pid, pos)
  for index, value in ipairs(breaking[pid]) do
    if vec3.equals(pos, value.pos) then
      return value, index
    end
  end
end

-- ========================network==========================

---@param state ns.breaking.states
---@param target {pos: vec3, id: int, pid: int, start: number}
---@param ignore_client neutron.class.client | nil
local function echo_state(state, target, ignore_client)
  local pos = target.pos

  local players = api.sandbox.players.get_in_radius(
    mp.convert_vector(pos), api.constants.render_distance
  )

  for name, _ in pairs(players) do
    if ignore_client and name == ignore_client.player.username then goto continue end

    local client = mp.accounts.get_client_by_name(name)
    net_events.server.tell(packets.block_breaking, client, bson.serialize({ state, pos, target.id, target.pid }));

    ::continue::
  end
end

net_events.server.on(packets.block_breaking, function(client, bytes)
  local pid = client.player.pid;
  local state, pos, t_id, t_pid = unpack(bson.deserialize(bytes));

  if state == breaking_states.start then
  end
end)

mp.events.on(pack_id, packets.block_breaking, function(client, bytes)
  local pid        = client.player.pid
  ---@type [ ns.breaking.states, vec3 ]
  local args       = mp.bson.deserialize(bytes)
  local state, pos = unpack(args)

  if state == breaking_states.start then
    breaking[pid] = breaking[pid] or {}
    local target = { pos = pos, id = block.get(unpack(pos)), pid = pid, start = time.uptime() }
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
        return mp.events.tell(pack_id, packets.block_breaking, client,
          mp.bson.serialize(
            { breaking_states.interrupted, pos, target.id, target.pid, block.get_states(unpack(target.pos)) }
          )
        )
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

ns_events.on("l:block_broken", function(blockid, x, y, z, pid)
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
