local ns_events = require "shared/core/ns_events"
local nu = require "shared/utils/not_utils";
local system_controller = require "server/lib/system_controller"
local mp = nu.multiplayer
local logger = nu.Logger.new("not_survival");
local server = mp.api.server;

require "shared/player/data/manager"

if mp.mode ~= "standalone" then
  ns_events.on("world_tick", function()
    local players = server.sandbox.players.get_all();

    for _, _player in pairs(players) do
      ns_events.emit("player_tick", _player.pid, server.constants.tps.tps);
    end
  end)
end

local require_folder = require "shared/utils/require_folder"
require_folder "server/events"
local systems = require_folder "server/systems"

for _, system in pairs(systems) do
  system_controller:register(system)
end

ns_events.on("player_tick", function(pid, tps)
  system_controller:update(pid, tps);
end)

logger:println("I", "Сервер-сайд подтянулся.")
