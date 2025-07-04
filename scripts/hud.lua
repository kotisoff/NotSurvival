local resource = require "shared/utils/resource_func"

function on_hud_open(playerid)
  events.emit(resource("hud_open"), playerid);
end
