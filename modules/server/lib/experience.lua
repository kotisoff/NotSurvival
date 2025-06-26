local _nu = require "shared/utils/not_utils"

local mp = _nu.multiplayer.api.server
local data = require "shared/player/data"
local packets = require "shared/utils/declarations/packets"
local exp_shared = require "shared/lib/experience"

local pack_id = "not_survival"

local module = {}

function module.get_exp(pid)
  return data.get_status(pid, "xp")
end

function module.get_lvl(pid)
  return exp_shared.calc_lvl(module.get_exp(pid))
end

function module.update(pid)
  local client = mp.accounts.get_client(mp.accounts.get_account_by_name(player.get_name(pid)))
  mp.events.tell(pack_id, packets.update_player_data, client,
    mp.bson.serialize({
      data.get_category_index("status"),
      data.get_field_index("status", "xp"),
      module.get(pid)
    })
  )
end

function module.set_xp(pid, value)
  data.set_field(pid, "status", "xp", value)
  module.update(pid)
end

function module.set_lvl(pid, value)
  local exp = exp_shared.calc_total(value)
  module.set_xp(pid, exp)
end

function module.give(pid, amount)
  module.set_xp(module.get_exp(pid) + amount)
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
end
