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

-- =============================================

---@param category string | number
---@return integer
local function get_category_index(category)
  if type(category) == "number" then return category end
  return table.index(module.Categories, category)
end

---@param category string|number
---@param field string|nil
---@return integer|nil
local function get_field_index(category, field)
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
  if mp.api.server then
    local entid = player.get_entity(pid);
    local entity = entities.get(entid);

    local component = entity.components[pack_id .. ":player"];
    component.ARGS.pid = pid;

    return component.ARGS
  else
    ---@diagnostic disable-next-line: return-type-mismatch
    return session_storage
  end
end

---@alias attribute_field "health" | "hunger" | "saturation" | "oxygen" | "armor"

---Get player data as array. I.e.: health, hunger, etc.
---@param pid number
---@param field string | attribute_field | nil
---@return any
function module.get_data(pid, field)
  local component = get_component(pid)

  local data = component[get_category_index("data")]

  if field then
    return data[table.index(PlayerDataKeys, field)]
  end

  return data
end

---Get player data as dict. I.e.: health, hunger, etc.
---@param pid number
function module.get_data_dict(pid)
  local data = module.get_data(pid)
  return table.to_dict(data, module.CategoryFields.data)
end

---Get player attributes. I.e. max health, max hunger, etc.
---@param pid number
---@param field string | attribute_field | nil
---@return any
function module.get_attributes(pid, field)
  local component = get_component(pid)

  local data = component[get_category_index("attributes")]

  if field then
    return data[table.index(PlayerDataKeys, field)]
  end

  return data
end

---Get player attributes as dict. I.e.: health, hunger, etc.
---@param pid number
function module.get_attributes_dict(pid)
  local data = module.get_attributes(pid)
  return table.to_dict(data, module.CategoryFields.attributes)
end

---@alias status_field "xp" | "gamemode" | "dead" | "effects"

---Get player status as. I.e.: death, effects
---@param pid number
---@param field string | status_field | nil
---@return any
function module.get_status(pid, field)
  local component = get_component(pid)

  local data = component[get_category_index("status")]

  if field then
    return data[table.index(PlayerStatusKeys, field)]
  end

  return data
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

---@param pid number
---@param category "data" | "attributes" | "status"
---@param field string | attribute_field | status_field
---@param value any
function module.set_field(pid, category, field, value)
  local component = get_component(pid)
  local c_id = get_category_index(category)
  local f_id = get_field_index(category, field)

  if f_id then
    component[c_id][f_id] = value
  end
end

-- ================Network====================

---@param username string
---@param category "data" | "status" | "attributes"
---@param field string | nil
function module.update(username, category, field)
  local f_id = get_field_index(category, field)
  local c_id = get_category_index(category)


  if mp_server then
    local account = mp_server.accounts.get_account_by_name(username)
    local client = mp_server.accounts.get_client(account)

    local get_fun = module["get_" .. category]
    local data = get_fun(client.player.pid, field)

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

    mp_server.events.tell(pack_id, packets.request_player_data, client,
      mp_server.bson.serialize({ c = c_id, f = f_id, d = data }))
    return
  elseif mp_client then
    mp_client.events.send(pack_id, packets.request_player_data,
      mp_client.bson.serialize({ c = c_id, f = f_id }))
    return
  end
end

if mp_server then
  ---@param client neutron.class.client
  events.on("server:client_connected", function(client)
    local component = get_component(client.player.pid)
    local c_id = get_category_index("data")

    if not component[c_id] or #component[c_id] ~= #PlayerData then
      for index, value in ipairs(module.Categories) do
        component[index] = module['new_' .. value]()
      end
    end
  end)

  mp_server.events.on(pack_id, packets.request_player_data, function(client, bytes)
    local args = mp_server.bson.deserialize(bytes)

    local category = module.Categories[args.c]
    local field = nil
    if args.f then
      field = module.Categories[category][args.f]
    end

    module.update(client.player.username, category, field)
  end)
end

if mp_client then
  session_storage = {
    module.new_data(),
    module.new_attributes(),
    module.new_status()
  }

  mp_client.events.on(pack_id, packets.request_player_data, function(bytes)
    local args = mp_client.bson.deserialize(bytes)

    if not args.d then return end

    if args.f then
      session_storage[args.c][args.f] = args.d
    else
      session_storage[args.c] = args.d
    end
  end)
end

return module
