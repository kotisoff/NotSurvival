local ns_events = require "shared/core/ns_events";
local prefix    = require "shared/utils/prefix"

function on_hud_open(playerid)
  ns_events.emit("hud_open", playerid);

  hud.open_permanent(prefix("survival_hud"))
end

function on_hud_render()
  ns_events.emit("hud_render");
end
