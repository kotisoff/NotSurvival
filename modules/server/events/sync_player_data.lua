local net_events          = require "shared/net/utils/net_events"
local request_compression = require "shared/net/compression/player_data_request"
local manager             = require "shared/player/data/manager"

net_events.server.on(net_events.packets.update_player_data, function(client, bytes)
  local category, field = request_compression.from_bytes(bytes);

  manager.sync(category, field, client);
end)
