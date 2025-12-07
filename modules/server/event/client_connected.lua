if pack.is_installed("server") then
  ---@param client neutron.class.client
  events.on("server:client_connected", function(client)
    player.set_instant_destruction(client.player.pid, false)
    print(string.format("Игрок %s(%d) присоединился", client.player.username, client.player.pid))
  end)
end
