local mp            = require "shared/lib/not_utils".multiplayer;
local manager       = require "shared/player/data/manager"
local loaders       = require "shared/lib/loaders/main";
local net_events    = require "shared/net/utils/net_events"
local destruction   = require "shared/lib/destruction"

local ResourcesData = require "shared/net/messages/ResourcesData";
---@cast ResourcesData neutron.server.messages.Message

---@param client neutron.class.client
ns_events.on("player_ready", function(client)
  -- FIXME: а нахуя?
  -- time.post_runnable(function()
  --   local success, status = pcall(manager.get_status, client.player.pid);

  --   if success and not status.init then
  --     local x, y, z = player.get_pos(client.player.pid);

  --     player.set_spawnpoint(client.player.pid, x, y, z);

  --     status.init = true;
  --   end
  -- end)

  destruction.update_player_rules(client.player.pid);


  if mp.mode ~= "standalone" then
    local bytes = loaders.compressed_data;

    ResourcesData:tell(client, { hash = loaders.local_hash, data = bytes });

    logger:println("I",
      string.format("Sent %s bytes of resources to %s(%s)", #bytes, client.player.username, client.player.pid)
    );
  end

  -- print(string.format("Игрок %s(%d) присоединился", client.player.username, client.player.pid))
end)
