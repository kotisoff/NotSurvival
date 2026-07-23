local ns_events         = require "shared/core/ns_events";
local system_controller = require "server/lib/system_controller";
local data_storage      = require "shared/core/data_storage"

ns_events.on("player_tick", function(pid, tps)
  system_controller:update(pid, tps);
end)

---@param client neutron.class.client
ns_events.on("player_ready", function(client)
  system_controller:register_player(client.player.pid);
end)

---@param client neutron.class.client
ns_events.on("client_disconnected", function(client)
  system_controller:remove_player(client.player.pid);

  data_storage.save("players");
end)
