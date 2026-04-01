local properties = require "shared/core/config".properties;
local mineable   = require "shared/lib/loaders/tags/mineable"
local module     = {};

---@alias ns.breaking.tool_type "pickaxe" | "axe" | "shovel" | "sword" | "hoe"

---@class ns.breaking.tool
---@field type ns.breaking.tool_type[]
---@field speed number

---@param itemid int
---@param blockid int
function module.is_tool_effective(itemid, blockid)
  if not mineable.data[blockid] then return false end;

  local props = item.properties[itemid];
  if not props or not props[properties.tool] then return false end;

  ---@type ns.breaking.tool
  local tool_props = props[properties.tool];

  for _, tool_type in ipairs(tool_props.type or {}) do
    if table.has(mineable.data[blockid], tool_type) then
      return true;
    end
  end

  return false;
end

---@return number
function module.get_tool_speed(itemid)
  local props = item.properties[itemid]
  if not props or not props[properties.tool] then return 1 end
  return props[properties.tool].speed or 1 --[[@as number]]
end

return module
