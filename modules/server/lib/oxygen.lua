local _nu = require "shared/utils/not_utils"

local mp = _nu.multiplayer.api.server
local data = require "shared/player/data"
local packets = require "shared/utils/declarations/packets"

local pack_id = "not_survival"

local module = {}

---@return number
function module.get(pid)
  return data.get_data(pid, "oxygen")
end

---@return number
function module.get_max(pid)
  return data.get_attributes(pid, "oxygen")
end

function module.update(pid)
  local client = mp.accounts.get_client(mp.accounts.get_account_by_name(player.get_name(pid)))
  mp.events.tell(pack_id, packets.update_player_data, client,
    mp.bson.serialize({
      data.get_category_index("data"),
      data.get_field_index("data", "oxygen"),
      module.get(pid)
    })
  )
end

function module.set(pid, value)
  local max = module.get_max(pid)
  local new_val = math.clamp(value, 0, max)

  data.set_field(pid, "data", "oxygen", new_val)
  module.update(pid)
end

function module.full(pid)
  module.set(pid, module.get_max(pid))
end

function module.add(pid, amount)
  local value = module.get(pid)
  module.set(pid, value + (amount or 1))
end

return module
