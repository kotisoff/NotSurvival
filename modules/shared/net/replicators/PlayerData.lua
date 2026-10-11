local Replicator = require "shared/net/replicators/_Replicator";
local stats_loader = require "shared/player/data/stats_loader"

local M = Replicator.prototype;

ns_events.on("first_tick", function()
	M = Replicator.new(Replicator.ids.player_data, stats_loader.build_scheme());
end)

return M;
