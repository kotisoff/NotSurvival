local mp_api = require("mp_api/init")();
local player_data = require "server/utils/player_data";

local switch = {
  data = player_data.get_data,
  attributes = player_data.get_attributes,
  status = player_data.get_status,
  damage_source = player_data.get_damage_source
}

mp_api.server.on("get_player_data", function(player, type)
  local data = switch[type](player.pid);

  mp_api.server.send("set_player_data", player.username, data, type);
end)
