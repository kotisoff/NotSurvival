local data = require "shared/player/data"
local resource = require "utils/resource_func"

events.on(resource("hud_open"), function()
  local pid = hud.get_player()
  player.set_instant_destruction(pid, false)
  player.set_infinite_items(pid, false)
end)
