local DealKnockback = require "shared/net/messages/DealKnockback"

---@cast DealKnockback neutron.client.messages.Message
DealKnockback:on(function(data)
  local vel = data.velocity;

  local pid = hud.get_player()

  local player_vel = { player.get_vel(pid) }
  local new_vel = vec3.add(player_vel, vel)

  player.set_vel(pid, unpack(new_vel))
end)
