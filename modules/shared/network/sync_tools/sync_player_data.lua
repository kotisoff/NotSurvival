local net_events          = require "shared/network/utils/net_events"
local data_compression    = require "shared/network/compression/player_data"
local request_compression = require "shared/network/compression/player_data_request";
local manager             = require "shared/player/data/manager"
local mp                  = require "shared/utils/not_utils".multiplayer;

local module              = {};

---@param category str
---@param field str | nil
---@param client neutron.class.client | nil Only on server
function module.update(category, field, client)
  if mp.mode == "server" and client then
    local data = manager.get_store(client.player.pid)

    net_events.server.tell(net_events.packets.update_player_data, client,
      data_compression.to_bytes(category, field, field and data[field] or data)
    );
  elseif mp.mode == "client" then
    net_events.client.send(net_events.packets.update_player_data, request_compression.to_bytes(category, field));
  elseif mp.mode == "server" then
    error("Client не указан!");
  end
end

return module;
