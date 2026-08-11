local death      = require "shared/player/stats/death"
local net_events = require "shared/net/utils/net_events"

net_events.server.on(net_events.packets.player_respawn, function(client)
  death.revive(client.player.pid);
end)
