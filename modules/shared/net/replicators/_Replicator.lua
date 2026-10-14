local mp              = require "shared/lib/multiplayer";
local constants       = require "shared/core/constants"
local packet_registry = require "shared/net/packet_registry"

local Replicator      = mp.api[mp.side].replications;

---@class ns.net.ReplicatorRegistry
local module          = {};

local keys            = {
	"create_listener", "create_private_replica", "create_public_replica",
	"get_replica", "remove_replica"
}

local function unwrap(obj, event, schema_provider)
	if not obj.value then
		obj.value = module.new(event, schema_provider());
	end

	return obj.value
end

---@param event string
---@param schema table
function module.new(event, schema)
	return Replicator.new(constants.pack_id, event, schema);
end

---@param event string
---@param schema_provider fun(): table
---@return neutron.server.replications.Replicator | neutron.client.replications.Replicator
function module.wrap_new(event, schema_provider)
	local obj = { value = nil };

	for _, key in ipairs(keys) do
		obj[key] = function(_, ...)
			local value = unwrap(obj, event, schema_provider);

			return value[key](value, ...);
		end
	end

	return obj;
end

module.ids = packet_registry.replicators;

return module;
