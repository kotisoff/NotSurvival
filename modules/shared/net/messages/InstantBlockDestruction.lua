local Message = require "shared/net/messages/_Message";

local BLOCKID_TYPE = "uint16";

local M = Message.new(
	Message.ids.instant_block_destruction,
	{
		block = BLOCKID_TYPE,
		pos = "Triple<int32, uint8, int32>",
		states = "Nilable<uint16>"
	}
);

return M;
