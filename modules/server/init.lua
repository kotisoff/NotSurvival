local ns_events = require "shared/core/ns_events"
local nu = require "shared/utils/not_utils";
local system_controller = require "server/lib/system_controller"
local loaders = require "shared/lib/loaders/main";
local mp = nu.multiplayer
local logger = nu.Logger.new("not_survival");
local server = mp.api.server;

require "shared/player/data/manager"

ns_events.on("first_tick", function()
  loaders.reload();
end)

if mp.mode ~= "standalone" then
  ns_events.on("world_tick", function()
    local players = server.sandbox.players.get_all();

    for _, _player in pairs(players) do
      ns_events.emit("player_tick", _player.pid, server.constants.tps.tps);
    end
  end)

  ---@param client neutron.class.client
  events.on("server:client_connected", function(client)
    ns_events.emit("player_connected", client)
  end)
else
  ns_events.on("first_tick", function()
    local pid = hud.get_player()

    local identity = server.sandbox.players.get_by_pid(pid).identity;
    local client = server.accounts.by_identity.get_client(identity);
    -- Вот эта ↑ залупень ↑ нужна чтобы ide не ругалась, по идее я могу ваще без identity клиента спиздить в standalone.

    ns_events.emit("player_connected", client);
  end)
end

local require_folder = require "shared/utils/require_folder"
require_folder "server/events"
local systems = require_folder "server/systems"

for _, system in pairs(systems) do
  system_controller:register(system);
end

ns_events.on("player_tick", function(pid, tps)
  system_controller:update(pid, tps);
end)

ns_events.on("player_connected", function(pid)
  system_controller:register_player(pid);
end)

ns_events.on("player_disconnected", function(pid)
  system_controller:remove_player(pid);
end)

require "server/commands";

logger:println("I", "Сервер-сайд подтянулся.")
