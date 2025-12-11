local properties       = require "shared/core/config".properties;
local module           = {}

---@enum ns.breaking.states
module.breaking_states = {
  start = 0,
  broken = 1,
  interrupted = 2
}

---@return number
function module.get_tool_speed(pid)
  local inv, slot = player.get_inventory(pid)
  local itemid = inventory.get(inv, slot)

  local props = item.properties[itemid]
  if not props then return 1 end
  return props[properties.tool.speed] or 1 --[[@as number]]
end

function module.get_speed_multiplier(pid)
  local speed = module.get_tool_speed(pid)
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

---@param pid int|nil
---@param blockid int
function module.get_breaking_speed(pid, blockid)
  local multiplier = 1
  if pid then
    multiplier = module.get_speed_multiplier(pid)
  end

  return 1 / math.max(module.get_durability(blockid), 0.00001) * multiplier
end

---@param progress number [0,1]
function module.get_breaking_texture(progress)
  return string.format(
    "cracks/cracks_%s", math.floor(progress * 11)
  )
end

---@return number, number, number
function module.get_block_center(pos)
  ---@diagnostic disable-next-line: redundant-return-value
  return unpack(vec3.add(pos, 0.5))
end

return module
