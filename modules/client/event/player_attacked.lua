local mp        = require "shared/utils/not_utils".multiplayer.api.client;
local ns_events = require "shared/utils/ns_events"
local constants = require "constants"
local packets   = require "shared/utils/declarations/packets"

local pack_id   = constants.pack_id;

ns_events.on("player_attacked", function(attacked_pid)
  mp.events.send(pack_id, packets.player_attacked, mp.bson.serialize({ attacked_pid }));
end)
