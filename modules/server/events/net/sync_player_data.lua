local manager           = require "shared/player/data/manager"

local PlayerDataRequest = require "shared/net/messages/PlayerDataRequest"
---@cast PlayerDataRequest neutron.server.messages.Message

PlayerDataRequest:on(function(client, data)
  if not data.category then
    return logger:println("E", "Нас кто то пытаетя наебать.");
  end

  manager.sync(data.category, data.field, client);
end)
