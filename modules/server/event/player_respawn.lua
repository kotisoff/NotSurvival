local mp      = require "shared/utils/not_utils".multiplayer.api.server
local packets = require "shared/utils/declarations/packets"
local death   = require "server/lib/death"
local pack_id = "not_survival"

mp.events.on(pack_id, packets.player_respawn, function(client)
  death.revive(client.player.pid)
end)
