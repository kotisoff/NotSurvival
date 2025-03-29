local mp_api = require("mp_api/init")();
local player_data = require "server/utils/player_data";

local switch = {
  data = player_data.get_data,
  attributes = player_data.get_attributes,
  status = player_data.get_status,
  damage_source = player_data.get_damage_source
}

mp_api.server.on("set_player_data", function(player, playerdata, type)
  local data = switch[type](player.pid);
  for key, _ in pairs(data) do
    data[key] = playerdata[key];
  end
end)
