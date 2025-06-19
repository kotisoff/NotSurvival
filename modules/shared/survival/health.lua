local player_data = require "shared/player/data"

local module = {}

---@class ns.shared.health.DamageSource
local DamageSource = {
  source = { 0, 0, 0 },
  knockback = true,
  type = "ns.damage.nothing",
  attacker = nil,
  amount = 0
}

function module.get(pid)
  return player_data.get_data(pid).health
end

function module.get_max(pid)
  return player_data.get_attributes(pid).health
end
