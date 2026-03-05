local net_events = require "shared/network/utils/net_events"
local bson       = require "shared/utils/bson"

net_events.client.on(net_events.packets.deal_knockback, function(bytes)
  local vel = bson.deserialize(bytes)
  local pid = hud.get_player()

  local player_vel = { player.get_vel(pid) }
  local new_vel = vec3.add(player_vel, vel)

  player.set_vel(pid, unpack(new_vel))
end)
