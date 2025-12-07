local mp = require "shared/utils/not_utils".multiplayer;

mp.handle_event(
  "server:client_connected", "not_survival:first_tick",
  ---@param client neutron.class.client
  function(client)
    player.set_instant_destruction(client.player.pid, false)
    print(string.format("Игрок %s(%d) присоединился", client.player.username, client.player.pid))
  end,
  {
    "client"
  }
)
