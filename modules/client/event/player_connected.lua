local data = require "shared/player/data_manager"
local resource = require "shared/utils/resource_func"
local allow_cheats = require "client/hooks/allow_cheats"

events.on(resource("hud_open"), function()
  local pid = hud.get_player()
  local gm = data.get_status(pid);

  if gm ~= 1 then
    allow_cheats(false);
  end
end)
