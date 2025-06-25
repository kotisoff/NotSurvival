local data = require "shared/player/data"
local resource = require "shared/utils/resource_func"

events.on(resource("hud_open"), function()
  local pid = hud.get_player()
  -- Мда, юзлесс ивент
end)
