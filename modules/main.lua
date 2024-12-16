local PACK_ID = "not_survival"; function resource(name) return PACK_ID .. ":" .. name end

require("drop/block_events");
require("survival/loops/_main");
local variables = require("utility/variables");
require("utility/movement_controller");
require("drop/drop_loader");

require("drop/block_destroy")

local first_player_tick = true;
events.on(resource("player_tick"), function(pid)
  if variables.get_player_data(pid).gamemode == 0 and first_player_tick then
    hud.open_permanent(resource("survival_hud"))
  end
  first_player_tick = false;
end)
