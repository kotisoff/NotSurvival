local ns_events         = require "shared/core/ns_events";
local system_controller = require "server/lib/system_controller";
local data_storage      = require "shared/core/data_storage"

ns_events.on("player_tick", function(pid, tps)
  system_controller:update(pid, tps);
end)

ns_events.on("player_ready", function(pid)
  system_controller:register_player(pid);
end)

ns_events.on("client_disconnected", function(pid)
  system_controller:remove_player(pid);
end)
