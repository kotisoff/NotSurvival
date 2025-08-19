local module = {};

---@class PlayerData
---@field health number
---@field hunger number
---@field saturation number
---@field oxygen number
---@field armor number

---@class PlayerStatus
---@field xp number
---@field gamemode number
---@field dead boolean
---@field effects effect[]

module.Categories = { "data", "attributes", "status" }

local PlayerStatusKeys = { "xp", "gamemode", "dead", "effects" }
local PlayerDataKeys = { "health", "hunger", "saturation", "oxygen", "armor" }

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

return module;
