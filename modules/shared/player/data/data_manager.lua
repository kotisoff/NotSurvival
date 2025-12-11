local not_utils = require "shared/utils/not_utils"
local data_types = require "shared/player/data_types"
local mp = not_utils.multiplayer
local mp_client, mp_server = mp.api.client, mp.api.server
local packets = require "shared/utils/declarations/packets"
local constants = require "constants";
local pack_id = constants.pack_id;

local compression = require "shared/compression/player_data";

local module = {}

local session_storage = {
  data = {},
  attributes = {},
  status = {}
}

-- =============================================

local PlayerData = {
  health = 20,
  hunger = 20,
  saturation = 20,
  oxygen = 20,
  armor = 0
}
local PlayerAttributes = {
  health = 20,
  hunger = 20,
  saturation = 20,
  oxygen = 20,
  armor = 20
}

-- =============================================

---@type [ number, number, boolean, ns.player.Status.effect[] ]
local PlayerStatus = {
  xp = 0,
  gamemode = 0,
  dead = false,
  effects = {}
}

-- =============================================

---@param pid number
---@return [ {}, {}, {} ]
local function get_component(pid)
  if mp_server then
    local entid = player.get_entity(pid);
    local entity = entities.get(entid);

    local component = entity.components[pack_id .. ":player"];

    return component.ARGS
  else
    ---@diagnostic disable-next-line: return-type-mismatch
    return session_storage
  end
end

---@param pid int
---@param cat ns.categories
---@return any
function module.get(pid, cat)
  local component = get_component(pid)

  local data = component[cat]

  return data
end

---Get player data. I.e.: health, hunger, etc.
---@param pid number
---@return PlayerData
function module.get_data(pid)
  return module.get(pid, "data")
end

---Get player attributes. I.e. max health, max hunger, etc.
---@param pid number
---@return PlayerData
function module.get_attributes(pid)
  return module.get(pid, "attributes")
end

---Get player status. I.e.: death, effects
---@param pid number
---@return PlayerStatus
function module.get_status(pid)
  return module.get(pid, "status")
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
  return { data = module.new_data(), attributes = module.new_attributes(), status = module.new_status() }
end

---@param pid number
---@param category "data" | "attributes" | "status"
---@param field string | ns.attributefield | ns.statusfield
---@param value any
function module.set_field(pid, category, field, value)
  local component = get_component(pid)
  component[category][field] = value
end

-- ================Network====================

---@param category ns.player.data_categories
---@param field ns.player.data_field.base | ns.player.data_field.status | str | nil
---@param client neutron.class.client | nil Only on server
function module.update(category, field, client)
  if mp_server and client then
    local data = module.get(client.player.pid, category)

    if field then
      data = data[field]
    end

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
      compression.to_bytes(category, field, data)
    )
    return
  elseif mp_client then
    mp_client.events.send(pack_id, packets.update_player_data,
      mp_client.bson.serialize(
        {
          data_types.get_category_index(category),
          field and data_types.get_field_index(category, field) or 0
        }
      )
    )
    return
  end
end

if mp_server then
  mp_server.events.on(pack_id, packets.update_player_data, function(client, bytes)
    local args = mp_server.bson.deserialize(bytes)
    local c, f = unpack(args)

    local category = data_types.Categories[c]

    local field = nil
    if (f or 0) > 0 then
      field = data_types.Categories[category][f]
    end

    module.update(category, field, client)
  end)
end

if mp_client then
  session_storage = module.new_player_data()

  mp_client.events.on(pack_id, packets.update_player_data, function(bytes)
    local category, field, data = compression.from_bytes(bytes);

    if field then
      session_storage[category][field] = data
    else
      session_storage[category] = data
    end
  end)
end

return module
