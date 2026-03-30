local net_events  = require "shared/net/utils/net_events"
local compression = require "shared/net/compression/player_data"
local manager     = require "shared/player/data/manager"

net_events.client.on(net_events.packets.update_player_data, function(bytes)
  local category, field, data = compression.from_bytes(bytes);

  local store = manager.session;

  if field then
    store[category][field] = data;
  else
    store[category] = data;
  end
end)
