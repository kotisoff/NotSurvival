local net_events  = require "shared/net/utils/net_events"
local compression = require "shared/net/compression/player_data"
local manager     = require "shared/player/data/manager"

net_events.client.on(net_events.packets.update_player_data, function(bytes)
  local category, field, data = compression.from_bytes(bytes);
  local pid = hud.get_player();

  print('got data')
  print(string.format("ae %s %s %s %s", pid, category, field, data))

  if field then
    manager.set(pid, category, field, data);
  elseif type(data) == "table" then
    for key, value in pairs(data) do
      manager.set(pid, category, key, value);
    end
  end
end)
