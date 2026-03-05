local _nu = require "shared/utils/not_utils"
local mp = _nu.multiplayer.api.server
local data = require "shared/player/data_types"
local packets = require "shared/utils/declarations/packets"

local constants = require "constants";
local pack_id = constants.pack_id;

local module = {}

---@param pid int
---@param cat ns.player.data_categories
---@param field ns.player.data_field.status | ns.player.data_field.base | str
---@param value any
function module.update(pid, cat, field, value)
  local status, client = pcall(mp.accounts.get_client_by_name, player.get_name(pid))
  if not status or not client then return end

  mp.events.tell(pack_id, packets.update_player_data, client,
    mp.bson.serialize({
      data.get_category_index(cat),
      data.get_field_index(cat, field),
      value
    })
  )
end

return module
--TODO: перенести всё это недоразумение подальше отсюда
