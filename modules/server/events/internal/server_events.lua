local mp = require "shared/lib/not_utils".multiplayer;
local server = mp.api.server;

local ns_events = require "shared/core/ns_events";

if vc.is_headless() then
  ns_events.on("world_tick", function()
    local players = server.sandbox.players.get_all();

    for _, _player in pairs(players) do
      ns_events.emit("player_tick", _player.pid, server.constants.tps.tps);
    end
  end)

  ---@param client neutron.class.client
  events.on("server:client_connected", function(client)
    ns_events.emit("client_connected", client);
  end)

  ---@param client neutron.class.client
  events.on("server:on_player_ready", function(client)
    ns_events.emit("player_ready", client);
  end)

  events.on("server:client_disconnected", function(client)
    ns_events.emit("client_disconnected", client)
  end)
elseif mp.mode == "standalone" then
  ---@type number
  local pid = nil;

  local function require_pid()
    if not pid then
      pid = hud.get_player();
    end

    return pid;
  end

  local emit = function(event)
    require_pid();

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

  ns_events.on("world_quit", function()
    emit("client_disconnected");
  end)
end
