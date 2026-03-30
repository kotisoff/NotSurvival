local ns_events  = require "shared/core/ns_events"
local net_events = require "shared/net/utils/net_events"
local bson       = require "shared/utils/bson"

ns_events.on("player_attacked", function(attacked_pid)
  net_events.client.send(net_events.packets.player_attacked, bson.serialize({ attacked_pid }))
end)
