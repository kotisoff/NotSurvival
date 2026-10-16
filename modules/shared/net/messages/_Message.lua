local mp              = require "shared/lib/multiplayer";
local constants       = require "shared/core/constants"
local packet_registry = require "shared/net/packet_registry"

local Message         = mp.api[mp.side].messages;

---@class ns.net.MessageRegistry
local module          = {};

---@param event string
---@param schema table
function module.new(event, schema)
  return Message.new(constants.pack_id, event, schema);
end

---@param event string
---@param schema_provider fun(): table
function module.lazy_new(event, schema_provider)
  return Message.lazy_new(constants.pack_id, event, schema_provider);
end

module.ids = packet_registry.messages;

return module;
