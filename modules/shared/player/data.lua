local not_utils = require "shared/utils/not_utils"
local mp = not_utils.multiplayer
local mp_client, mp_server = mp.api.client, mp.api.server
local packets = require "shared/utils/declarations/packets"
local pack_id = "not_survival"

local module = {}

local session_storage = { {}, {}, {} }

-- =============================================

local PlayerData = { 20, 20, 20, 20, 0 }
local PlayerAttributes = { 20, 20, 20, 20, 20 }
local PlayerDataKeys = { "health", "hunger", "saturation", "oxygen", "armor" }

---@class PlayerData
---@field health number
---@field hunger number
---@field saturation number
---@field oxygen number
---@field armor number

-- =============================================

---@alias effect { identifier: string, level: number, time_left: number }

---@type [ number, number, boolean, effect[] ]
local PlayerStatus = { 0, 0, false, {} }
local PlayerStatusKeys = { "xp", "gamemode", "dead", "effects" }

---@class PlayerStatus
---@field xp number
---@field gamemode number
---@field dead boolean
---@field effects effect[]

-- =============================================

module.Categories = { "data", "attributes", "status" }
module.CategoryFields = { data = PlayerDataKeys, attributes = PlayerDataKeys, status = PlayerStatusKeys }

---@alias ns.categories "data" | "attributes" | "status"
---@alias ns.attributefield "health" | "hunger" | "saturation" | "oxygen" | "armor"
---@alias ns.statusfield "xp" | "gamemode" | "dead" | "effects"

-- =============================================

---@param category ns.categories|string|number
---@return integer
function module.get_category_index(category)
  if type(category) == "number" then return category end
  return table.index(module.Categories, category)
end

---@param category ns.categories|string|number
---@param field ns.statusfield|ns.attributefield|string|nil
---@return integer|nil
function module.get_field_index(category, field)
  if type(field) ~= "string" then return field end

  local c_name = category
  if type(category) == "number" then
    c_name = module.Categories[category]
  end
  local Keys = module.CategoryFields[c_name]
  return table.index(Keys, field)
end

-- =============================================

---@param pid number
---@return [ {}, {}, {} ]
local function get_component(pid)
  if mp_server then
    local entid = player.get_entity(pid);
    local entity = entities.get(entid);
    if not entity then return {} end

    local component = entity.components[pack_id .. ":player"];

    return component.ARGS
  else
    ---@diagnostic disable-next-line: return-type-mismatch
    return session_storage
  end
end

---@param pid int
---@param cat ns.categories
---@param field ns.attributefield|ns.statusfield|str|nil
---@return any
function module.get(pid, cat, field)
  local component = get_component(pid)

  local data = component[module.get_category_index(cat)]
  if field then
    return data[module.get_field_index(cat, field)]
  end

  return data
end

---Get player data as array. I.e.: health, hunger, etc.
---@param pid number
---@param field string | ns.attributefield | nil
---@return any
function module.get_data(pid, field)
  return module.get(pid, "data", field)
end

---Get player data as dict. I.e.: health, hunger, etc.
---@param pid number
function module.get_data_dict(pid)
  local data = module.get_data(pid)
  return table.to_dict(data, module.CategoryFields.data)
end

---Get player attributes. I.e. max health, max hunger, etc.
---@param pid number
---@param field string | ns.attributefield | nil
---@return any
function module.get_attributes(pid, field)
  return module.get(pid, "attributes", field)
end

---Get player attributes as dict. I.e.: health, hunger, etc.
---@param pid number
function module.get_attributes_dict(pid)
  local data = module.get_attributes(pid)
  return table.to_dict(data, module.CategoryFields.attributes)
end

---Get player status as. I.e.: death, effects
---@param pid number
---@param field string | ns.statusfield | nil
---@return any
function module.get_status(pid, field)
  return module.get(pid, "status", field)
end

---Get player status as dict. I.e.: health, hunger, etc.
---@param pid number
function module.get_status_dict(pid)
  local data = module.get_status(pid)
  return table.to_dict(data, module.CategoryFields.status)
end

function module.new_data()
  ---@diagnostic disable-next-line: undefined-field
  return table.copy(PlayerData);
end

function module.new_status()
  ---@diagnostic disable-next-line: undefined-field
  return table.copy(PlayerStatus);
end

function module.new_attributes()
  ---@diagnostic disable-next-line: undefined-field
  return table.copy(PlayerAttributes);
end

function module.new_player_data()
  return { module.new_data(), module.new_attributes(), module.new_status() }
end

---@param pid number
---@param category "data" | "attributes" | "status"
---@param field string | ns.attributefield | ns.statusfield
---@param value any
function module.set_field(pid, category, field, value)
  local component = get_component(pid)
  local c_id = module.get_category_index(category)
  local f_id = module.get_field_index(category, field)

  if f_id then
    component[c_id][f_id] = value
  end
end

-- ================Network====================

---@param category ns.categories
---@param field ns.attributefield | ns.statusfield | str | nil
---@param client neutron.class.client | nil Only on server
function module.update(category, field, client)
  local f_id = module.get_field_index(category, field)
  local c_id = module.get_category_index(category)


  if mp_server and client then
    local data = module.get(client.player.pid, category, field)

    -- ============standalone===============
    if mp.mode == "standalone" then
      if field then
        session_storage[category][field] = data
      else
        session_storage[category] = data
      end
      return
    end
    -- =====================================

    mp_server.events.tell(pack_id, packets.update_player_data, client --[[@as neutron.class.client]],
      mp_server.bson.serialize({ c_id, f_id or 0, data })
    )
    return
  elseif mp_client then
    mp_client.events.send(pack_id, packets.update_player_data,
      mp_client.bson.serialize({ c_id, f_id or 0 })
    )
    return
  end
end

if mp_server then
  mp_server.events.on(pack_id, packets.update_player_data, function(client, bytes)
    local args = mp_server.bson.deserialize(bytes)
    local c, f = unpack(args)

    local category = module.Categories[c]

    local field = nil
    if (f or 0) > 0 then
      field = module.Categories[category][f]
    end

    module.update(category, field, client)
  end)
end

if mp_client then
  session_storage = module.new_player_data()

  mp_client.events.on(pack_id, packets.update_player_data, function(bytes)
    local args = mp_client.bson.deserialize(bytes)
    local c, f, d = unpack(args)

    if type(d) == "nil" then return end

    if f > 0 then
      session_storage[c][f] = d
    else
      session_storage[c] = d
    end
  end)
end

return module
