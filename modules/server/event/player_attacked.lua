local pack_id = "not_survival"

local mp = require "shared/utils/not_utils".multiplayer.api.server
local packets = require "shared/utils/declarations/packets"
local health = require "server/lib/health"


mp.events.on(pack_id, packets.player_attacked, function(client, bytes)
  local args = mp.bson.deserialize(bytes)
  local attacker, pid = unpack(args)

  print("Attacker:", attacker, "player:", pid)
  health.damage(pid, 1, { damage_type = "ns.damage.hit", source = { player.get_pos(attacker) } })
end)
