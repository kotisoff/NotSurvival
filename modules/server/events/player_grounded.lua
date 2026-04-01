local mp = require "shared/utils/not_utils".multiplayer.api.server
local net_events = require "shared/net/utils/net_events"
local health = require "shared/player/stats/health"
local fall_distance = require "shared/utils/fall_distance"

net_events.server.on(net_events.packets.player_grounded, function(client, bytes)
  print(string.format("Игрок %s(%d) упал", client.player.username, client.player.pid))
  local args = mp.bson.deserialize(bytes)
  local velocity = unpack(args)

  if velocity then
    local damage = fall_distance.calculate_damage(velocity)
    if damage <= 0 then return end

    local x, y, z = player.get_pos(client.player.pid)

    health.damage(
      client.player.pid, damage,
      { source = { x, y - 0.5, z }, damage_type = "ns.damage.fall", do_knockback = false, sound_settings = { volume = 0.8, pitch = math.rand(0.8, 1.2) } }
    )
  end
end)
