-- ========================header===========================
local config                   = require "shared/core/config";
local constants                = require "shared/core/constants";
local mp                       = require "shared/utils/not_utils".multiplayer;
local ns_events                = require "shared/core/ns_events"
local logger                   = require "shared/core/logger"
local net_events               = require "shared/net/utils/net_events"
local storage                  = require "shared/core/data_storage".data

local data_compression         = require "shared/net/compression/player_data";
local data_request_compression = require "shared/net/compression/player_data_request";

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
---@field effects ns.player.Status.effect[]
---@field init bool

---@alias ns.player.Status.effect { identifier: string, level: number, time_left: number }

---@alias ns.player.data_categories "data" | "attributes" | "status"
---@alias ns.player.data_field.base "health" | "hunger" | "saturation" | "oxygen"
---@alias ns.player.data_field.status "xp" | "gamemode" | "dead" | "death_location" | "effects" | "init"

-- =========================================================


---@param v { init: int, max: int }
---@type ns.player.Base
local PlayerBase = table.map(table.copy(config.player.base), function(i, v) return v.init end);

---@param v { init: int, max: int }
---@type ns.player.Base
local PlayerAttributes = table.map(table.copy(config.player.base), function(i, v) return v.max end);

---@type ns.player.Status
local PlayerStatus = {
  xp = 0, gamemode = 0, dead = false, death_location = { 0, 0, 0 }, effects = {}, init = false
}

-- =========================================================

local module = {
  ---@type { data: ns.player.Base, attributes: ns.player.Base, status: ns.player.Status }
  session = {}
};

-- Shared

---@param pid int
---@return { data: ns.player.Base, attributes: ns.player.Base, status: ns.player.Status }
function module.get_store(pid)
  -- TODO: investigate где сука у нас всё ломается и обнуляется.
  -- TODO: вспомнить чё где обнуляется, ибо доёб не понят.

  if mp.mode == "client" then
    return module.session;
  else
    -- local info = debug.getinfo(3, "S");
    -- debug.print(info);

    local identity = mp.api.server.sandbox.players.get_by_pid(pid).identity;

    if not storage.players then
      storage.players = {};
    end

    if not storage.players[identity] then
      if config.debug.log_misc then
        logger:println("I", string.format("Created new survival data for %s(%s)", identity, pid));
      end

      storage.players[identity] = {
        data = module.new_base(),
        attributes = module.new_attributes(),
        status = module.new_status()
      }
    end

    return storage.players[identity];
  end
end

---@return ns.player.Base
function module.new_base()
  return table.copy(PlayerBase)
end

---@return ns.player.Base
function module.new_attributes()
  return table.copy(PlayerAttributes)
end

---@return ns.player.Status
function module.new_status()
  return table.copy(PlayerStatus)
end

function module.get_data(pid)
  return module.get_store(pid).data;
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
  if value == "nil" then
    local info = debug.getinfo(2, "S");
    logger:println("W", string.format("setting explicit nil value to player field! %s:%s in %s:%s"), category, field,
      info.source, info.lastlinedefined);
  end

  local store = module.get_store(pid);
  store[category][field] = value;

  if mp.mode ~= "standalone" then
    ns_events.emit("__set_player_data", pid, category, field, value);
  end

  mp.as_server(function(server, mode)
    local identity = server.sandbox.players.get_by_pid(pid).identity;
    local client = server.accounts.by_identity.get_client(identity);

    module.sync(category, field, client);
  end)
end

---@param category str
---@param field str | nil
---@param client neutron.class.client | nil Only on server
function module.sync(category, field, client)
  if mp.mode == "server" and client then
    local store = module.get_store(client.player.pid);
    local data = store[category];

    local value;
    if field then
      value = data[field];
    else
      value = data;
    end

    net_events.server.tell(net_events.packets.update_player_data, client,
      data_compression.to_bytes(category, field, value)
    );
  elseif mp.mode == "client" then
    net_events.client.send(net_events.packets.update_player_data, data_request_compression.to_bytes(category, field));
  elseif mp.mode == "server" then
    error("Client не указан!");
  elseif mp.mode == "standalone" then
    local pid = hud.get_player();
    local store = module.get_store(pid);

    local value
    if field then
      value = store[category][field]
    else
      value = store[category]
    end

    ns_events.emit("__set_player_data", pid, category, field, value);
  end
end

module.session = {
  data = module.new_base(),
  attributes = module.new_attributes(),
  status = module.new_status()
};

return module;
