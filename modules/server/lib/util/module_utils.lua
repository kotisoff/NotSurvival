local _nu = require "shared/utils/not_utils"
local mp = _nu.multiplayer.api.server
local data = require "shared/player/data/utils"
local net_events = require "shared/network/utils/net_events"

local module = {}

---@deprecated better use player_data.update
---@param pid int
---@param cat ns.player.data_categories
---@param field ns.player.data_field.status | ns.player.data_field.base | str
---@param value any
function module.update(pid, cat, field, value)
  local status, player = pcall(mp.sandbox.players.get_by_pid, pid)
  if not status or not player then return end

  local client = mp.accounts.by_identity.get_client(player.identity);

  net_events.server.tell(net_events.packets.update_player_data, client,
    mp.bson.serialize({
      data.get_category_index(cat),
      data.get_field_index(cat, field),
      value
    })
  )
end

return module
--TODO: перенести всё это недоразумение подальше отсюда
