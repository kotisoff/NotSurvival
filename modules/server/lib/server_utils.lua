local resource = require "shared/utils/resource_func"
local mp = require "shared/utils/not_utils".multiplayer
local module = {
  tps = 20
}

function module.get_player_event()
  local event = resource("player_tick")
  if events.handlers["server:main_tick"] then event = "server:main_tick" end
  return event
end

if mp.mode == "server" then
  local start = time.uptime()
  local ticks = 0

  local event = resource("player_tick")
  if events.handlers["server:main_tick"] then events = "server:main_tick" end

  events.on(event, function(_, tps)
    ticks = ticks + 1
    if ticks == tps then
      ticks = 0
      local timeout = time.uptime() - start
      start = time.uptime()

      module.tps = tps / timeout
    end
  end)
end

return module
