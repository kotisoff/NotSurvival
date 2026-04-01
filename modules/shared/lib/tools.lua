local properties = require "shared/core/config".properties;
local module     = {};

---@alias ns.breaking.tool_type "pickaxe" | "axe" | "shovel" | "sword" | "hoe"

---@class ns.breaking.tool
---@field type ns.breaking.tool_type[]
---@field speed number

---@return number
function module.get_tool_speed(pid)
  local inv, slot = player.get_inventory(pid)
  local itemid = inventory.get(inv, slot)

  local props = item.properties[itemid]
  if not props or not props[properties.tool] then return 1 end
  return props[properties.tool].speed or 1 --[[@as number]]
end

return module
