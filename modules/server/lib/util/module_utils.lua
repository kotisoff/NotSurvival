local _nu = require "shared/utils/not_utils"
local mp = _nu.multiplayer.api.server
local data = require "shared/player/data"
local packets = require "shared/utils/declarations/packets"

local pack_id = "not_survival"

local module = {}

---@param pid int
---@param cat ns.categories
---@param field ns.statusfield | ns.attributefield | str
---@param value any
function module.update(pid, cat, field, value)
  local client = mp.accounts.get_client(mp.accounts.get_account_by_name(player.get_name(pid)))
  mp.events.tell(pack_id, packets.update_player_data, client,
    mp.bson.serialize({
      data.get_category_index(cat),
      data.get_field_index(cat, field),
      value
    })
  )
end

return module
