local mp = require "shared/lib/not_utils".multiplayer;

local pack_id = require "shared/core/constants".pack_id;

local packets = {
  update_player_data = tohex(1),
  block_breaking = tohex(2),
  deal_knockback = tohex(3),
  food_eating = tohex(4),
  player_grounded = tohex(5),
  player_sprinting = tohex(6),
  player_respawn = tohex(7),
  resources_data = tohex(8)
}

local client = {};
local server = {};

mp.as_client(function(api, mode)
  local net_events = api.events;

  ---@param event str
  ---@param bytes bytearray
  function client.send(event, bytes)
    return net_events.send(pack_id, event, bytes);
  end

  ---@param event str
  ---@param func fun(bytes: bytearray)
  function client.on(event, func)
    return net_events.on(pack_id, event, func);
  end
end)

mp.as_server(function(api, mode)
  local net_events = api.events;

  ---@param event str
  ---@param bytes bytearray
  function server.echo(event, bytes)
    return net_events.echo(pack_id, event, bytes);
  end

  ---@param event str
  ---@param func fun(client: neutron.class.client, bytes: bytearray)
  function server.on(event, func)
    return net_events.on(pack_id, event, func);
  end

  ---@param event str
  ---@param client neutron.class.client
  ---@param bytes bytearray
  function server.tell(event, client, bytes)
    return net_events.tell(pack_id, event, client, bytes);
  end
end)

local module = {
  ---@deprecated
  client = client,
  ---@deprecated
  server = server,
  ---@deprecated
  packets = packets
}

return module;
