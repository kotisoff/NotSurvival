local mp = require "shared/lib/multiplayer";
local constants = require "shared/core/constants"

local replicator = mp.api[mp.side].replications;

local Replicator = replicator.new(constants.pack_id, "player")
