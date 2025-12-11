local mp        = require "shared/utils/not_utils".multiplayer.api.server
local packets   = require "shared/utils/declarations/packets"
local death     = require "shared/survival/death"
local constants = require "constants";
local pack_id   = constants.pack_id;

mp.events.on(pack_id, packets.player_respawn, function(client)
  death.revive(client.player.pid)
end)
