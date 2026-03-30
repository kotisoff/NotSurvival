local ns_events = require "shared/core/ns_events"
local data = require "shared/player/data/manager"
local allow_cheats = require "client/hooks/allow_cheats"

ns_events.on(("hud_open"), function()
  local pid = hud.get_player()
  local gm = data.get_status(pid);

  if gm ~= 1 then
    allow_cheats(false);
  end
end)
