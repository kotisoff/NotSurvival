-- ========================header===========================
local config          = require "shared/core/config";
local mp              = require "shared/lib/not_utils".multiplayer;
local data_storage    = require "shared/core/data_storage";
local stats_loader    = require "shared/player/data/stats_loader"
local PlayerData      = require "shared/net/replicators/PlayerData"

local storage         = data_storage.data;

-- =========================types===========================

---@class ns.player.Base
---@field health number
---@field hunger number
---@field saturation number
---@field oxygen number

---@class ns.player.Status
---@field xp number
---@field gamemode number
---@field dead boolean
---@field death_location vec3
-- -@field effects ns.player.Status.effect[]

---@alias ns.player.Status.effect { identifier: string, level: number, time_left: number }

---@alias ns.player.data_categories "base" | "attributes" | "status"
---@alias ns.player.data_field.base "health" | "hunger" | "saturation" | "oxygen"
---@alias ns.player.data_field.status "xp" | "gamemode" | "dead" | "death_location" | "effects" | "init"

-- =========================================================

-- ---@type ns.player.Base
-- local PlayerBase = table.map(
--   table.copy(config.player.base),
--   ---@param v { init: int, max: int }
--   function(i, v)
--     return v.init
--   end
-- );

-- ---@param v { init: int, max: int }
-- ---@type ns.player.Base
-- local PlayerAttributes = table.map(table.copy(config.player.base), function(i, v) return v.max end);

-- ---@type ns.player.Status
-- local PlayerStatus = {
--   xp = 0, gamemode = 0, dead = false, death_location = { 0, 0, 0 }, effects = {}, init = false
-- }

-- =========================================================

local module          = {};
local replica_storage = {};

-- Shared

---@param pid int
---@return { base: ns.player.Base, attributes: ns.player.Base, status: ns.player.Status }
function module.get_store(pid)
  if vc.is_client() then
    return module.session;
  else
    local identity = mp.api.server.sandbox.players.get_by_pid(pid).identity;

    if not replica_storage[identity] then
      if config.debug.log_misc then
        logger:println("I", string.format("Creating new survival data for %s(%s)", player.get_name(pid), pid));
      end

      local client = mp.api.server.accounts.by_identity.get_client(identity);
      local replica = PlayerData.unwrap();
      ---@cast replica neutron.server.replications.Replicator

      local value = {};
      if storage.players[identity] then
        value = storage.players[identity];
      else
        value = stats_loader.build();
      end

      replica_storage[identity] = replica:create_private_replica(pid, value, client);
    end

    return replica_storage[identity];
  end
end

---@param player neutron.class.player
function module.disconnect_replica(player)
  local replica = PlayerData.unwrap();

  if replica_storage[player.identity] then
    replica_storage[player.identity] = nil;
    replica:remove_replica(player.pid);
    return true;
  end
  return false;
end

function module.get_base(pid)
  return module.get_store(pid).base;
end

function module.get_attributes(pid)
  return module.get_store(pid).attributes;
end

function module.get_status(pid)
  return module.get_store(pid).status;
end

---@param pid int
---@param category ns.player.data_categories
---@param field str | ns.player.data_field.base | ns.player.data_field.status
function module.set(pid, category, field, value)
  if value == nil then
    local info = debug.getinfo(2, "S");
    logger:println("W", string.format("setting explicit nil value to player field! %s:%s in %s:%s"), category, field,
      info.source, info.lastlinedefined);
  end

  local store = module.get_store(pid);
  store[category][field] = value;
end

-- ---@param category str
-- ---@param field str | nil
-- ---@param client neutron.class.client | nil Only on server
-- function module.sync(category, field, client)
--   if mp.mode == "server" then
--     if client then
--       local store = module.get_store(client.player.pid);
--       local data = store[category];

--       local value;
--       if field then
--         value = data[field];
--       else
--         value = data;
--       end

--       net_events.server.tell(net_events.packets.update_player_data, client,
--         data_compression.to_bytes(category, field, value)
--       );
--     else
--       error("Client не указан!");
--     end
--   elseif mp.mode == "client" then
--     ---@cast PlayerDataRequest neutron.client.messages.Message
--     PlayerDataRequest:send({ category = category, field = field });
-- elseif mp.mode == "standalone" then
--   local pid = hud.get_player();
--   local store = module.get_store(pid);

--   local value
--   if field then
--     value = store[category][field]
--   else
--     value = store[category]
--   end

-- FIXME: without __set_player_data ui won't work
-- ns_events.emit("__set_player_data", pid, category, field, value);
--   end
-- end

---@type { base: ns.player.Base, attributes: ns.player.Base, status: ns.player.Status }
module.session = nil;

ns_events.on("hud_open", function(...)
  logger:println("I", "Creating survival data listener");

  local replica = PlayerData.unwrap();
  ---@cast replica neutron.client.replications.Replicator

  module.session = replica:create_listener(hud.get_player(), stats_loader.build());
end)

data_storage.on_save(function()
  for identity, replica in pairs(replica_storage) do
    storage.players[identity] = {};
    local _player = storage.players[identity];

    for key, value in pairs(replica) do
      if key ~= "_old_data" and key ~= "_client" then
        _player[key] = value;
      end
    end
  end
end, "players")

return module;
