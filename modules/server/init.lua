local ns_events = require "shared/utils/ns_events"
local nu = require "shared/utils/not_utils";
local mp = nu.multiplayer
local logger = nu.Logger.new("not_survival");
local server = mp.api.server;

require "shared/player/data_manager"
require "server/lib/util/server_utils"
require "server/commands"

if mp.mode ~= "standalone" then
  ns_events.on("world_tick", function()
    local players = server.sandbox.players.get_all();

    for _, _player in pairs(players) do
      ns_events.emit("player_tick", _player.pid, server.constants.tps.tps);
    end
  end)
end

local require_folder = require "shared/utils/require_folder"
require_folder "server/event"
require_folder "server/system"

logger:println("I", "Сервер-сайд подтянулся.")
