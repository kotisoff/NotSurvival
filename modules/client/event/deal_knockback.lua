local mp = require "shared/utils/not_utils".multiplayer.api.client
local packets = require "shared/utils/declarations/packets"

local packid = "not_survival"

mp.events.on(packid, packets.deal_knockback, function(bytes)
  local vel = mp.bson.deserialize(bytes)
  local pid = hud.get_player()

  local player_vel = { player.get_vel(pid) }
  local new_vel = vec3.add(player_vel, vel)

  player.set_vel(pid, unpack(new_vel))
end)
