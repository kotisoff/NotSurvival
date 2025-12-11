local module = {}

local gravity = 22.18

function module.calculate(velocity)
  return (velocity ^ 2) / (2 * gravity)
end

function module.calculate_damage(velocity)
  local distance = module.calculate(velocity)
  return math.floor(distance) - 3
end

return module
