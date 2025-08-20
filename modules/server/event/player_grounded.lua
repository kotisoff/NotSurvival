local constants = require "constants";
local pack_id = constants.pack_id;

local mp = require "shared/utils/not_utils".multiplayer.api.server
local packets = require "shared/utils/declarations/packets"
local health = require "shared/survival/health"
local fall_distance = require "shared/lib/fall_distance"

---@param client neutron.class.client
events.on("server:client_connected", function(client)
  print(string.format("Игрок %s(%d) присоединился", client.player.username, client.player.pid))
end)


mp.events.on(pack_id, packets.player_grounded, function(client, bytes)
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
