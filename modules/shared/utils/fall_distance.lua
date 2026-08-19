local module = {}

---Gravitation constant. Calculated manually.
local gravity = 22.18

---@param velocity number
---@param gravity_scale number
---@return number distance
function module.calculate(velocity, gravity_scale)
  gravity_scale = gravity_scale or 1;

  return (velocity ^ 2) / (2 * gravity * gravity_scale)
end

---@param velocity number
---@param gravity_scale number
---@return int damage
function module.calculate_damage(velocity, gravity_scale)
  local distance = module.calculate(velocity, gravity_scale)
  return math.max(math.floor(distance) - 3, 0)
end

return module
