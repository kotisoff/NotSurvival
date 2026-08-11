local mp         = require "shared/utils/not_utils".multiplayer;
local manager    = require "shared/player/data/manager"
local exp_shared = require "shared/utils/experience"

---@type ns.player.data_categories, ns.player.data_field.status
local cat, field = "status", "xp";

---@class ns.stat.exp
local module     = {};

-- ========================shared===========================

function module.get(pid)
  if not pid then pid = hud.get_player() end
  return manager.get_status(pid).xp or 0
end

function module.get_level(pid)
  return exp_shared.calc_level(module.get(pid))
end

function module.is_drainable(pid, amount)
  local xp = module.get(pid) - amount
  return xp > 0
end

function module.is_drainable_level(pid, amount)
  local lvl = module.get_level(pid) - amount
  return lvl > 0
end

-- ========================server===========================

mp.as_server(function(server, mode)
  ---Server side only
  ---@param pid int
  function module.set(pid, value)
    manager.set(pid, cat, field, value)
  end

  ---Server side only
  ---@param pid int
  function module.set_level(pid, value)
    local exp = exp_shared.calc_total(value)
    module.set(pid, exp)
  end

  ---Server side only
  ---@param pid int
  ---@param amount? number Default: 1
  function module.add(pid, amount)
    module.set(pid, module.get(pid) + (amount or 1))
  end

  ---Server side only
  ---@param pid int
  ---@param amount? number Default: 1
  function module.add_level(pid, amount)
    module.set_level(pid, module.get_level(pid) + (amount or 1))
  end

  ---Server side only
  ---@param pid int
  function module.drain(pid, amount)
    local xp = module.get(pid) - amount
    if xp < 0 then return false end
    module.set(pid, xp)
    return true
  end

  ---Server side only
  ---@param pid int
  function module.drain_level(pid, amount)
    local lvl = module.get_level(pid) - amount
    if lvl < 0 then return false end
    module.set_level(pid, lvl)
    return true
  end

  ---Server side only
  ---WIP
  function module.summon(pos, amount)
    return {}
  end
end)

return module
