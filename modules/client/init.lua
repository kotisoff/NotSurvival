local require_folder = require "utils/require_folder";
print("loading client events");
require_folder "client/events";
require_folder "client/game";
require "client/utils/player_data";

print("Клиент-сайд тута.")

local resource = require "utils/resource_func";

events.on(resource("hud_open"), function()
  print("Trying to open survival hud.");
  hud.open_permanent(resource("survival_hud"));
end)
