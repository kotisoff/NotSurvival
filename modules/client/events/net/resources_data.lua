local net_events = require "shared/net/utils/net_events"
local loaders    = require "shared/lib/loaders/main";
local logger     = require "shared/core/logger"

net_events.client.on(net_events.packets.resources_data, function(bytes)
  logger:println("I",
    string.format("Got %s bytes of resources", #bytes)
  );

  loaders.decompress(bytes);
end)
