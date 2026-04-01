local mp        = require "shared/utils/not_utils".multiplayer;
local ns_events = require "shared/core/ns_events"
local manager   = require "shared/player/data/manager"

---@param client neutron.class.client
ns_events.on("player_connected", function(client)
  local status = manager.get_status(client.player.pid);

  if not status.init then
    player.set_instant_destruction(client.player.pid, false)

    local x, y, z = player.get_pos(client.player.pid);

    player.set_spawnpoint(client.player.pid, x, y, z);
    player.set_pos(client.player.pid, x, y, z)
    mp.api.server.sandbox.players.sync_states(client.player, { pos = { x, y, z } });

    status.init = true;
  end

  -- print(string.format("Игрок %s(%d) присоединился", client.player.username, client.player.pid))
end)
