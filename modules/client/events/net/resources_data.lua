local loaders       = require "shared/lib/loaders/main";
local logger        = require "shared/core/logger"

local ResourcesData = require "shared/net/messages/ResourcesData";
---@cast ResourcesData neutron.client.messages.Message

---@param data { hash: string, data: bytearray }
ResourcesData:on(function(data)
  logger:println("I",
    string.format("Got %s bytes of resources (Hash: %s)", data.data, data.hash)
  )

  loaders.decompress(data.data, data.hash);
end)
