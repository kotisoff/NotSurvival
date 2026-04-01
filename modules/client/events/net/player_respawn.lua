local death      = require "shared/player/stats/death"
local net_events = require "shared/net/utils/net_events"

net_events.client.on(net_events.packets.player_respawn, function()
  death.close_overlay();
end)
