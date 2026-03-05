local module = {}
local sounds = require "shared/utils/sounds_registry"

---@class ns.shared.health.DamageSource
local DamageSource = {
  source = { 0, 0, 0 },
  knockback = true,
  type = "ns.damage.nothing",
  attacker = nil,
  amount = 0
}

local default_sound_type = "ns.damage.hit"

---@alias damage_types "ns.damage.hit" | "ns.damage.fall" | "ns.damage.drowning"

---@param type damage_types
function module.random_sound(type)
  return sounds.random(type) or sounds.random(default_sound_type)
end

function module.calculate_knockback(pid, source, knockback_multiplier)
  local playerpos = { player.get_pos(pid) }
  source = source or playerpos
  knockback_multiplier = knockback_multiplier or 6

  local knockback_vel = vec3.normalize(vec3.sub(playerpos, source))

  local vel = vec3.mul(knockback_vel, knockback_multiplier)

  return vel
end

return module
