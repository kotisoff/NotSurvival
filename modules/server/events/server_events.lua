local mp = require "shared/utils/not_utils".multiplayer;
local server = mp.api.server;

local ns_events = require "shared/core/ns_events";

if mp.mode == "server" then
  ns_events.on("world_tick", function()
    local players = server.sandbox.players.get_all();

    for _, _player in pairs(players) do
      ns_events.emit("player_tick", _player.pid, server.constants.tps.tps);
    end
  end)

  ---@param client neutron.class.client
  events.on("server:client_connected", function(client)
    ns_events.emit("client_connected", client)
  end)

  events.on("server:on_player_ready", function(client)
    ns_events.emit("player_ready", client);
  end)
elseif mp.mode == "standalone" then
  local emit = function(event)
    local pid = hud.get_player()

    local identity = server.sandbox.players.get_by_pid(pid).identity;
    local client = server.accounts.by_identity.get_client(identity);
    -- Вот эта ↑ залупень ↑ нужна чтобы ide не ругалась, по идее я могу ваще без identity клиента спиздить в standalone.

    ns_events.emit(event, client);
  end

  ns_events.on("hud_open", function()
    emit("client_connected");
  end);
  ns_events.on("first_tick", function()
    emit("player_ready");
  end);
end
