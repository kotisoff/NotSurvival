local mp            = require "shared/lib/multiplayer";
local constants     = require "shared/core/constants"
local registry      = require "shared/net/messages/registry"

local Message       = mp.api[mp.side].messages;

local PlayerRespawn = Message.new(constants.pack_id, registry.player_respawn, {})

return PlayerRespawn;
