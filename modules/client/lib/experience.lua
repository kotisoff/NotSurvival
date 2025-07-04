local data = require "shared/player/data"
local exp_shared = require "shared/lib/experience"

local module = {} -- тоже оптимизировать юзлесс.

function module.get_exp()
  local pid = hud.get_player()
  return data.get_status(pid, "xp")
end

function module.get_lvl()
  return exp_shared.calc_lvl(module.get_exp())
end

function module.can_drain(amount)
  local xp = module.get_exp() - amount
  return xp > 0
end

function module.can_drain_lvl(amount)
  local lvl = module.get_lvl() - amount
  return lvl > 0
end

return module
