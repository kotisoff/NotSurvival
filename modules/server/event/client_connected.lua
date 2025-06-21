local mp = require "utils/not_utils".multiplayer.api.server
local packets = require "utils/packets"

---@param client neutron.class.client
events.on("server:client_connected", function(client)
  player.set_instant_destruction(client.player.pid, false)
end)
