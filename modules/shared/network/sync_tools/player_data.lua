local net_events       = require "shared/network/utils/net_events"
local compression      = require "shared/network/compression/player_data"
local manager          = require "shared/player/data/manager"
local playerdata_utils = require "shared/player/data/utils";
local mp               = require "shared/utils/not_utils".multiplayer;


---@type neutron.shared.bson
local bson   = mp.as_any(function(side, mode) return side.bson end);

local module = {};

---@param category str
---@param field str | nil
---@param client neutron.class.client | nil Only on server
function module.update(category, field, client)
  if mp.mode == "server" and client then
    local data = manager.get_store(client.player.pid)

    net_events.server.tell(net_events.packets.update_player_data, client,
      compression.to_bytes(category, field, field and data[field] or data)
    );
  elseif mp.mode == "client" then
    local request = {
      playerdata_utils.get_category_index(category),
      field and playerdata_utils.get_field_index(category, field) or 0
    }

    net_events.client.send(net_events.packets.update_player_data, bson.serialize(request));
  elseif mp.mode == "server" then
    error("Client не указан!");
  end
end

return module;
