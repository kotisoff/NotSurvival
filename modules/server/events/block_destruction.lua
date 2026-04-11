local ns_events         = require "shared/core/ns_events"
local net_events        = require "shared/net/utils/net_events";
local mp                = require "shared/utils/not_utils".multiplayer;
local destruction_utils = require "shared/lib/destruction"
local logger            = require "shared/core/logger"
local config            = require "shared/core/config"

local api               = mp.api.server;
local bson              = api.bson;
local packets           = net_events.packets;
local breaking_states   = destruction_utils.breaking_states

---@type {pos: vec3, id: int, pid: int, start: number}[]
local players_breaking  = {}

-- =========================funcs===========================

local function calculate_breaking_deviation(expected_time)
  return math.max(0.15, expected_time * 0.1)
end

---@param state ns.breaking.states
---@param target {pos: vec3, id: int, pid: int, start: number}
---@param additional_data any[] | nil
local function tell_breaking_state(client, state, target, additional_data)
  local data = {
    state, target.pos, target.id, target.pid
  };

  if additional_data then
    for _, value in ipairs(additional_data) do
      table.insert(data, value)
    end
  end

  net_events.server.tell(packets.block_breaking, client, bson.serialize(data));
end

---@param state ns.breaking.states
---@param target {pos: vec3, id: int, pid: int, start: number}
---@param ignored_client neutron.class.client | nil
local function echo_breaking_state(state, target, ignored_client)
  local pos = target.pos

  local players = api.sandbox.players.get_in_radius(
    pos, api.constants.render_distance
  )

  local data = {
    state, pos, target.id, target.pid
  };

  -- if additional_data then
  --   for _, value in ipairs(additional_data) do
  --     table.insert(data, value)
  --   end
  -- end

  for _, mplayer in pairs(players) do
    if ignored_client and mplayer.username == ignored_client.player.username then goto continue end

    local client = api.accounts.by_identity.get_client(mplayer.identity);

    net_events.server.tell(packets.block_breaking, client, bson.serialize(data));

    ::continue::
  end
end

---@param bytes bytearray
local function deserialize_breaking_state(bytes)
  ---@type [ns.breaking.states, vec3, int ]
  local args = bson.deserialize(bytes);

  local state, pos, pid = unpack(args);

  return state, pos, pid;
end

-- ========================handler==========================

---@type table<ns.breaking.states, fun(state: ns.breaking.states, pos: vec3, blockid: int, client: neutron.class.client)>
local handlers = {};

handlers[breaking_states.start] = function(state, pos, blockid, client)
  if blockid == 0 then return end;

  local pid = client.player.pid;
  destruction_utils.update_player_rules(pid);

  if destruction_utils.get_durability(blockid) == 0 then
    ns_events.emit("l:block_broken", blockid, pos, pid);

    local instant_target = { pos = pos, id = blockid, pid = pid };
    echo_breaking_state(breaking_states.broken, instant_target);

    return;
  end

  if players_breaking[pid] then
    echo_breaking_state(breaking_states.interrupted, players_breaking[pid]);
    players_breaking[pid] = nil;
  end

  local target = {
    pos = pos, id = blockid, pid = pid, start = time.uptime()
  }

  players_breaking[pid] = target;

  echo_breaking_state(state, players_breaking[pid]);
end

handlers[breaking_states.interrupted] = function(state, pos, _, client)
  local pid = client.player.pid;

  local target = players_breaking[pid];

  if not target then
    return
  end

  if vec3.equals(target.pos, pos) then
    echo_breaking_state(state, target);
  end

  players_breaking[pid] = nil;
end

handlers[breaking_states.broken] = function(state, pos, blockid, client)
  local pid = client.player.pid;

  local target = players_breaking[pid];

  if not target then
    return
  end

  local durability = destruction_utils.get_durability(blockid);
  if durability > 0 then
    local timestamp = time.uptime();
    local total = timestamp - target.start;
    local expected_time = durability / destruction_utils.get_speed_multiplier(pid, blockid)
    local deviation = calculate_breaking_deviation(expected_time);

    -- mp.mode == "server" нужен для того чтобы не было ложных срабатываний в синглплеере.
    if (expected_time - deviation) >= total and mp.mode == "server" then
      tell_breaking_state(client, breaking_states.interrupted, target, { block.get_states(unpack(pos)) });
      echo_breaking_state(state, target, client);
      -- Конкретно здесь пакеты ломающему игроку и другим отличаются 5 параметром, а точнее его присутствием.

      if config.debug.log_anticheat then
        logger:println("W",
          string.format("anticheat: player %s(%s) tried to break block too fast", client.player.username, pid)
        )
      end

      return
    end

    echo_breaking_state(state, target);
    ns_events.emit("l:block_broken", target.id, target.pos, pid)

    players_breaking[pid] = nil;
  end
end

net_events.server.on(packets.block_breaking, function(client, bytes)
  local state, pos = deserialize_breaking_state(bytes) -- пакет от клиента хранит в себе только state и pos
  local block_id = block.get(unpack(pos));

  handlers[state](state, pos, block_id, client);
end)

-- ====================cleanup=players======================

local tick_count = 0;                 -- [0, 20]

ns_events.on("world_tick", function() -- чистим таргеты от игроков которые не в сети раз в секунду
  if tick_count >= 20 then
    for pid, target in pairs(players_breaking) do
      if not (api.sandbox.players.get_by_pid(pid) or {}).active then
        echo_breaking_state(breaking_states.interrupted, target);
        players_breaking[pid] = nil;
      end
    end

    tick_count = 0;
  else
    tick_count = tick_count + 1;
  end
end)

-- ======================block=drop=========================

local drop_utils = require "shared/utils/drop_utils"
local base_utils = require "base:util"

ns_events.on("l:block_broken", function(blockid, pos, pid)
  local x, y, z = unpack(pos);
  block.set(x, y, z, 0);

  inventory.use(player.get_inventory(pid));

  local ns_drop = drop_utils.block_loot(blockid)

  ---@type { items: {item: int,count:int,vel:vec3}[] }
  local drop = {
    items = base_utils.block_loot(blockid),
    experience = ns_drop.experience
  }

  -- Prepare center pos for drop
  local drop_pos = vec3.add(pos, 0.5)

  -- Validate drop
  for _, loot in ipairs(drop.items) do
    if loot.item then
      ---@type voxelcore.class.entity
      local entity = base_utils.drop(drop_pos, loot.item, loot.count)

      if mp.mode == "standalone" then
        local vel = vec3.spherical_rand(3)
        entity.rigidbody:set_vel(vel)
      end
    else
      debug.warning("Failed to get block drop id. Block: " .. block.name(blockid))
    end
  end

  ns_drop.callback(blockid, x, y, z, pid)
end)

--[[
  Credits to: MihailRis
    for original script of hand animation and block destruction
]]
