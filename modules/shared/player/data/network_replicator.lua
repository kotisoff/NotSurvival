local mp = require "shared/lib/multiplayer";
local constants = require "shared/core/constants"
local stats_loader = require "shared/player/data/stats_loader"

local replicator = mp.api[mp.side].replications;

local Replicator = replicator.new(constants.pack_id, "player", stats_loader.build_scheme())

return Replicator;
