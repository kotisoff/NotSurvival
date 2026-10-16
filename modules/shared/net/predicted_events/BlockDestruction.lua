local PredictedEvent = require "shared/net/predicted_events/_PredictedEvent"
local BlockDestructionLogic = require "shared/net/logic/BlockDestruction";

require "server/logic/BlockDestruction";
require "client/logic/BlockDestruction";

local BLOCKID_TYPE = "uint16";

local M = PredictedEvent.new(
	PredictedEvent.ids.block_destruction,
	{
		block = BLOCKID_TYPE,
		pos = "Triple<int32, uint8, int32>",
		pid = "var"
	},
	BlockDestructionLogic:build()
);

return M;
