local properties = require "utils/properties"
local module     = {}

function module.get_tool_speed(pid)
  local inv, slot = player.get_entity(pid)
  local itemid = inventory.get(inv, slot)

  local props = item.properties[itemid]
  if not props then return 1 end
  return props[properties.tool_speed] or 1
end

function module.get_speed_multiplier(pid)
  local speed = module.get_tool_speed()
  if not player.is_on_ground(pid) then
    speed = speed / 5
  end
  return speed
end

---@return number
function module.get_durability(id)
  local durability = block.properties[id]["base:durability"]
  if durability ~= nil then
    return durability
  end
  if block.get_model(id) == "X" then
    return 0.0
  end
  return 5.0
end

function module.get_breaking_speed(pid, blockid)
  return 1 / math.max(module.get_durability(blockid), 0.00001) * module.get_speed_multiplier(pid)
end

---@param progress number [0,1]
function module.get_breaking_texture(progress)
  return string.format(
    "cracks/cracks_%s", math.floor(progress * 11)
  )
end

return module
