local data         = require "shared/player/data/manager"
local allow_cheats = require "client/hooks/allow_cheats"
local health       = require "shared/player/stats/health"


ns_events.on("first_tick", function()
  local pid = hud.get_player()
  local success, status = pcall(data.get_status, pid);

  if not success then
    return
  end

  allow_cheats(health.is_invulnerable(pid));
end)
