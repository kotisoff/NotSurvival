local resource = require "shared/utils/resource_func"
local mp = require "shared/utils/not_utils".multiplayer
local module = {
}

function module.get_player_event()
  local event = resource("player_tick")
  -- if events.handlers["server:main_tick"] then event = "server:main_tick" end
  return event
end

return module
