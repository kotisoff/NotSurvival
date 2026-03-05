local mp         = require "shared/utils/not_utils".multiplayer;
local sync_data  = require "shared/network/sync_tools/sync_player_data"
local data       = require "shared/player/data/manager"
local exp_shared = require "shared/utils/experience"
local net_utils  = require "shared/network/utils/net_utils"

---@type ns.player.data_categories, ns.player.data_field.status
local cat, field = "status", "xp";

local module     = {}

-- ========================shared===========================

function module.get_exp(pid)
  if not pid then pid = hud.get_player() end
  return data.get_status(pid).xp or 0
end

function module.get_lvl(pid)
  return exp_shared.calc_lvl(module.get_exp(pid))
end

function module.can_drain(pid, amount)
  local xp = module.get_exp(pid) - amount
  return xp > 0
end

function module.can_drain_lvl(pid, amount)
  local lvl = module.get_lvl(pid) - amount
  return lvl > 0
end

-- ========================server===========================

mp.as_server(function(server, mode)
  ---Server side only
  ---@param pid int
  function module.set_xp(pid, value)
    data.set(pid, cat, field, value)
    sync_data.update(cat, field, net_utils.server.get_client_by_pid(pid))
  end

  ---Server side only
  ---@param pid int
  function module.set_lvl(pid, value)
    local exp = exp_shared.calc_total(value)
    module.set_xp(pid, exp)
  end

  ---Server side only
  ---@param pid int
  function module.give(pid, amount)
    module.set_xp(pid, module.get_exp(pid) + amount)
  end

  ---Server side only
  ---@param pid int
  function module.drain(pid, amount)
    local xp = module.get_exp(pid) - amount
    if xp < 0 then return false end
    module.set_xp(pid, xp)
    return true
  end

  ---Server side only
  ---@param pid int
  function module.drain_lvl(pid, amount)
    local lvl = module.get_lvl(pid) - amount
    if lvl < 0 then return false end
    module.set_lvl(pid, lvl)
    return true
  end

  ---Server side only
  ---WIP
  function module.summon(pos, amount)
    return {}
  end
end)

return module
