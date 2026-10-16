local mp = require "shared/lib/multiplayer";
local constants = require "shared/core/constants"
local packet_registry = require "shared/net/packet_registry"

local PredictedEvent = mp.api[mp.side].predicted_events;

---@class ns.net.PredictedEvent
local module = {};

---@param event string
---@param schema table
---@param config neutron.client.predicted_events.config | neutron.server.predicted_events.config
function module.new(event, schema, config)
	return PredictedEvent.new(constants.pack_id, event, schema, config);
end

module.ids = packet_registry.predicted_events;

return module;
