local mp              = require "shared/lib/multiplayer";
local constants       = require "shared/core/constants"
local packet_registry = require "shared/net/packet_registry"

local Replicator      = mp.api[mp.side].replications;

---@class ns.net.ReplicatorRegistry
local module          = {};

---@param event string
---@param schema table
function module.new(event, schema)
	return Replicator.new(constants.pack_id, event, schema);
end

---@param event string
---@param schema_provider fun(): table
function module.lazy_new(event, schema_provider)
	return Replicator.lazy_new(constants.pack_id, event, schema_provider)
end

module.ids = packet_registry.replicators;

return module;
