local mp          = require "shared/utils/not_utils".multiplayer;
local ns_events   = require "shared/core/ns_events"
local manager     = require "shared/player/data/manager"
local loaders     = require "shared/lib/loaders/main";
local net_events  = require "shared/net/utils/net_events"
local logger      = require "shared/core/logger"
local destruction = require "shared/lib/destruction"

---@param client neutron.class.client
ns_events.on("player_ready", function(client)
  print("Вызываем плауер реди");

  time.post_runnable(function()
    local success, status = pcall(manager.get_status, client.player.pid);

    if success and not status.init then
      local x, y, z = player.get_pos(client.player.pid);

      player.set_spawnpoint(client.player.pid, x, y, z);
      player.set_pos(client.player.pid, x, y, z);

      status.init = true;
    end
  end)

  destruction.update_player_rules(client.player.pid);


  if mp.mode ~= "standalone" then
    local bytes = loaders.compressed_data;

    net_events.server.tell(net_events.packets.resources_data, client, bytes);
    print("кидаем залупу на клиент");

    logger:println("I",
      string.format("Sent %s bytes of resources to %s(%s)", #bytes, client.player.username, client.player.pid)
    );
  end

  -- print(string.format("Игрок %s(%d) присоединился", client.player.username, client.player.pid))
end)
