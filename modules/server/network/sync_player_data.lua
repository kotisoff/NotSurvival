local net_events          = require "shared/network/utils/net_events"
local request_compression = require "shared/network/compression/player_data_request"
local player_data         = require "shared/network/sync_tools/sync_player_data"

net_events.server.on(net_events.packets.update_player_data, function(client, bytes)
  local category, field = request_compression.from_bytes(bytes);

  player_data.update(category, field, client);
end)
