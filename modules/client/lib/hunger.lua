local sounds = require "shared/lib/sounds_registry"
local data = require "shared/player/data"
local properties = require "shared/utils/declarations/properties"

local module = {}

function module.get_hunger()
  local pid = hud.get_player()
  return data.get_data(pid, "hunger")
end

function module.get_max_hunger()
  local pid = hud.get_player()
  return data.get_attributes(pid, "hunger")
end

function module.get_saturation()
  local pid = hud.get_player()
  return data.get_data(pid, "saturation")
end

function module.get_max_saturation()
  local pid = hud.get_player()
  return data.get_attributes(pid, "saturation")
end

local food_type = {
  ["not_survival:potion"] = "drink",
  ["not_survival:food"] = "food"
}

---@return food_type|nil
function module.get_food_type(itemid)
  local props = item.properties[itemid]
  local type = nil
  for _, key in pairs(properties.food.types) do
    if props[key] then
      type = food_type[key]
    end
  end
  return type
end

return module
