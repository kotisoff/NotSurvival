local registry = require "shared/net/messages/_Message";

local M = registry.new(registry.ids.resources_data, {
	hash = "string",
	data = "bytearray"
})

return M;
