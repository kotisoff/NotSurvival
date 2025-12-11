local module = {};

local PlayerStatusKeys = { "xp", "gamemode", "dead", "effects" }
local PlayerDataKeys = { "health", "hunger", "saturation", "oxygen", "armor" }

module.Categories = { "data", "attributes", "status" }
module.CategoryFields = { data = PlayerDataKeys, attributes = PlayerDataKeys, status = PlayerStatusKeys }

---@param category ns.player.data_categories|string|number
---@return integer
function module.get_category_index(category)
  if type(category) == "number" then return category end
  return table.index(module.Categories, category)
end

---@param category ns.player.data_categories|string|number
---@param field ns.player.data_field.base|ns.player.data_field.status|string|nil
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
