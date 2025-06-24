local module = {}

---@class ns.shared.health.DamageSource
local DamageSource = {
  source = { 0, 0, 0 },
  knockback = true,
  type = "ns.damage.nothing",
  attacker = nil,
  amount = 0
}

local damage_sounds = {
  hit = {
    "not_survival/damage/hit1",
    "not_survival/damage/hit2",
    "not_survival/damage/hit3"
  },
  fall = {
    "not_survival/damage/fallsmall",
    "not_survival/damage/fallbig1",
    "not_survival/damage/fallbig2"
  }
}
local default_sound_type = "hit"

function module.random_sound(type)
  local sounds = damage_sounds[type] or damage_sounds[default_sound_type];
  return sounds[math.random(#sounds)];
end

function module.calculate_knockback(pid, source, knockback_multiplier)
  local playerpos = { player.get_pos(pid) }
  source = source or playerpos
  knockback_multiplier = knockback_multiplier or 6

  local player_vel = { player.get_vel(pid) }
  local knockback_vel = vec3.normalize(vec3.sub(playerpos, source))

  local vel = vec3.add(player_vel, vec3.mul(knockback_vel, knockback_multiplier))

  return vel
end

return module
