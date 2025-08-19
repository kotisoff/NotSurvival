local module_utils = require "server/lib/util/module_utils"
local data = require "shared/player/data_manager"
local exp_shared = require "shared/lib/experience"

---@type ns.categories, ns.statusfield
local cat, field = "status", "xp";

local module = {}

function module.get_exp(pid)
  return data.get_status(pid).xp or 0
end

function module.get_lvl(pid)
  return exp_shared.calc_lvl(module.get_exp(pid))
end

function module.set_xp(pid, value)
  data.set_field(pid, cat, field, value)
  module_utils.update(pid, cat, field, value)
end

function module.set_lvl(pid, value)
  local exp = exp_shared.calc_total(value)
  module.set_xp(pid, exp)
end

function module.give(pid, amount)
  module.set_xp(pid, module.get_exp(pid) + amount)
end

function module.can_drain(pid, amount)
  local xp = module.get_exp(pid) - amount
  return xp > 0
end

function module.drain(pid, amount)
  local xp = module.get_exp(pid) - amount
  if xp < 0 then return false end
  module.set_xp(pid, xp)
  return true
end

function module.can_drain_lvl(pid, amount)
  local lvl = module.get_lvl(pid) - amount
  return lvl > 0
end

function module.drain_lvl(pid, amount)
  local lvl = module.get_lvl(pid) - amount
  if lvl < 0 then return false end
  module.set_lvl(pid, lvl)
  return true
end

---WIP
function module.summon(pos, amount)
  return {}
end

return module
