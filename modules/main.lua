local PACK_ID = PACK_ID or "not_survival"; function resource(name) return PACK_ID .. ":" .. name end

local variables = require("utility/variables");

require "api";
require "drop/index";
require "player/index";
require "survival/index";
require "utility/index";

local first_player_tick = true;
events.on(resource("player_tick"), function(pid)
  if variables.get_player_data(pid).gamemode == 0 and first_player_tick then
    hud.open_permanent(resource("survival_hud"))
  end
  first_player_tick = false;
end)
