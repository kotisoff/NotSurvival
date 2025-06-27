local _mp = require "shared/utils/not_utils".multiplayer
local mode = _mp.mode
local mp = _mp.api.server

require "shared/player/data"
require "server/lib/util/server_utils"

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

print("Сервер-сайд подтянулся.")
