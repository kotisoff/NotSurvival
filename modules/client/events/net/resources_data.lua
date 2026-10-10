local loaders       = require "shared/lib/loaders/main";

local ResourcesData = require "shared/net/messages/ResourcesData";
---@cast ResourcesData neutron.client.messages.Message

---@param data { hash: string, data: bytearray }
ResourcesData:on(function(data)
  logger:println("I",
    string.format("Got %s bytes of resources", #data.data)
  )

  loaders.decompress(data.data, data.hash);
end)
