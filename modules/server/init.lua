local nu = require "shared/utils/not_utils";
local _mp = nu.multiplayer
local logger = nu.Logger.new("not_survival");
local mode = _mp.mode
local mp = _mp.api.server

require "shared/player/data_manager"
require "server/lib/util/server_utils"
require "server/commands"

local resource = require "shared/utils/resource_func"

if mode ~= "standalone" then
  events.on(resource("world_tick"), function(tps)
    local players = mp.sandbox.players.get_all()

    for name, _player in pairs(players) do
      events.emit(resource("player_tick"), _player.pid, tps)
    end
  end)
end

local require_folder = require "shared/utils/require_folder"
require_folder "server/event"
require_folder "server/system"

logger:println("I", "Сервер-сайд подтянулся.")
