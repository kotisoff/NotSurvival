local Message      = require "shared/net/messages/_Message"
local stats_loader = require "shared/player/data/stats_loader"
local _Replicator  = require "shared/net/replicators/_Replicator"

local function nullabling(schema)
	local Nilable = {}
	for key, typ in pairs(schema) do
		if type(typ) == "string" then
			Nilable[key] = "Nilable<" .. typ .. ">"
		else
			Nilable[key] = nullabling(typ)
		end
	end
	return Nilable
end

local function prepare_schema(schema)
	schema = nullabling(schema);
	schema._rep_id = "var";

	return schema;
end

-- HACK: Catches replicator diff packets and uses them to update ui.
local M = Message.new(_Replicator.ids.player_data, prepare_schema(stats_loader.build_schema()))

return M;
