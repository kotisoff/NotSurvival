---@param client neutron.class.client
events.on("server:client_connected", function(client)
  player.set_instant_destruction(client.player.pid, false)
end)
