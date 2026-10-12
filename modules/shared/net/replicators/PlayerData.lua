local Replicator = require "shared/net/replicators/_Replicator";
local stats_loader = require "shared/player/data/stats_loader"

local M = Replicator.wrap_new(Replicator.ids.player_data, stats_loader.build_schema());

return M;
