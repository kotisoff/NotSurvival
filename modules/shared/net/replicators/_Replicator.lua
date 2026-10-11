local mp              = require "shared/lib/multiplayer";
local constants       = require "shared/core/constants"
local packet_registry = require "shared/net/packet_registry"

local Replicator      = mp.api[mp.side].replications;

---@class ns.net.ReplicatorRegistry
local module          = {};

---@type neutron.client.replications.Replicator | neutron.server.replications.Replicator
module.prototype      = nil;

---@param event string
---@param schema table
function module.new(event, schema)
	return Replicator.new(constants.pack_id, event, schema);
end

module.ids = packet_registry.replicators;

return module;
