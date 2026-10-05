local mp          = require "shared/lib/multiplayer";
local constants   = require "shared/core/constants"
local registry    = require "shared/net/messages/registry"

local Message     = mp.api[mp.side].messages;

local StartEating = Message.new(constants.pack_id, registry.start_eating, { state = "boolean" })

return StartEating;
