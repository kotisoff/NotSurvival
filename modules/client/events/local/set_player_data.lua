local ns_events = require "shared/core/ns_events"

ns_events.on("__set_player_data", function(pid, category, field, value)
  if not field then
    for key1, value1 in pairs(value) do
      ns_events.emit("__update_hud", pid, category, key1, value1);
    end
  else
    ns_events.emit("__update_hud", pid, category, field, value);
  end
end)
