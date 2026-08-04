local ns_events = require "shared/core/ns_events"
local data = require "shared/player/data/manager"
local death = require "shared/player/stats/death";
local allow_cheats = require "client/hooks/allow_cheats"


ns_events.on("first_tick", function()
  local pid = hud.get_player()
  local success, status = pcall(data.get_status, pid);

  if not success then
    return
  end

  allow_cheats(death.is_invulnerable(pid));
end)
