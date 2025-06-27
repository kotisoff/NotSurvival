local pack_id = "not_survival"

local mp = require "shared/utils/not_utils".multiplayer.api.server
local packets = require "shared/utils/declarations/packets"
local health = require "server/lib/health"

mp.events.on(pack_id, packets.player_attacked, function(client, bytes)
  local args = mp.bson.deserialize(bytes)
  local attacker = unpack(args)

  health.damage(client.player.pid, 1,
    { damage_type = "ns.damage.hit", source = vec3.sub({ player.get_pos(attacker) }, { 0, 1, 0 }) })
end)
