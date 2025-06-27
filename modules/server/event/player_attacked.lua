local pack_id = "not_survival"

local mp = require "shared/utils/not_utils".multiplayer.api.server
local packets = require "shared/utils/declarations/packets"
local health = require "server/lib/health"
local fall_distance = require "shared/lib/fall_distance"


mp.events.on(pack_id, packets.player_attacked, function(client, bytes)
  local args = mp.bson.deserialize(bytes)
  local victim = unpack(args)

  health.damage(victim, 1,
    { damage_type = "ns.damage.hit", source = vec3.sub({ player.get_pos(client.player.pid) }, { 0, 2, 0 }) })
end)
