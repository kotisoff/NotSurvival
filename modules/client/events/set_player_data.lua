local mp_api = require("mp_api/init")();
local player_data = require "client/utils/player_data";

mp_api.client.on("set_player_data", function(data, type, parameter)
  if parameter then
    player_data[type][parameter] = data;
  else
    player_data[type] = data;
  end
end)
