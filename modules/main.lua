local resource = require "utility/resource_func"

local variables = require("player/variables");

require "api";
require "drop_system/init";
require "game/init";
require "survival/init";

local first_player_tick = true;
events.on(resource("player_tick"), function(pid)
  if variables.get_player_data(pid).gamemode == 0 and first_player_tick then
    hud.open_permanent(resource("survival_hud"))
  end
  first_player_tick = false;
end)
