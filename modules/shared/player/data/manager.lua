-- ========================header===========================
local config = require "shared/core/config";
local constants = require "constants";
local mp = require "shared/utils/not_utils".multiplayer;

-- =========================types===========================

---@class ns.player.Base
---@field health number
---@field hunger number
---@field saturation number
---@field oxygen number
---@field armor number

---@class ns.player.Status
---@field xp number
---@field gamemode number
---@field dead boolean
---@field effects ns.player.Status.effect[]

---@alias ns.player.Status.effect { identifier: string, level: number, time_left: number }

---@alias ns.player.data_categories "data" | "attributes" | "status"
---@alias ns.player.data_field.base "health" | "hunger" | "saturation" | "oxygen" | "armor"
---@alias ns.player.data_field.status "xp" | "gamemode" | "dead" | "effects"

-- =========================================================


---@param v { init: int, max: int }
---@type ns.player.Base
local PlayerBase = table.map(table.copy(config.player.base), function(i, v) return v.init end);

---@param v { init: int, max: int }
---@type ns.player.Base
local PlayerAttributes = table.map(table.copy(config.player.base), function(i, v) return v.max end);

---@type ns.player.Status
local PlayerStatus = {
  xp = 0, gamemode = 0, dead = false, effects = {}
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
  if mp.mode == "client" then
    return module.session;
  else
    local entid = player.get_entity(pid);
    local entity = entities.get(entid);
    local component_name = string.format("%s:player", constants.pack_id);

    return entity:require_component(component_name).ARGS;
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
  local store = module.get_store(pid);
  store[category][field] = value;
end

module.session = {
  data = module.new_base(),
  attributes = module.new_attributes(),
  status = module.new_status()
};

return module;
