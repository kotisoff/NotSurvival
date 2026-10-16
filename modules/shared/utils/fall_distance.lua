local module = {}

---Gravitation magic constant. From: src/world/Level.cpp:29
local gravity = 22.6

---@param velocity number
---@param gravity_scale? number
---@param drag? number
---@return number distance
function module.calculate(velocity, gravity_scale, drag)
  gravity_scale = gravity_scale or 1;
  drag = drag or 0;

  local g = gravity * gravity_scale;

  if drag <= 0 then
    return (velocity ^ 2) / (2 * g)
  end

  local vt = g / drag;
  if velocity >= vt then return math.huge end;

  return -(g / (drag * drag)) * math.log(1 - drag * velocity / g) - velocity / drag
end

---@param distance number
---@param min_damage_height? number
---@return int damage
function module.calculate_damage(distance, min_damage_height)
  min_damage_height = min_damage_height or 3;
  return math.max(math.round(distance - min_damage_height), 0)
end

return module
