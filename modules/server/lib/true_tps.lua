local resource = require "utils/resource_func"
local module = {
  tps = 20
}

local start = time.uptime()
local ticks = 0

local event = resource("player_tick")

events.on(event, function(_, tps)
  ticks = ticks + 1
  if ticks == tps then
    ticks = 0
    local timeout = time.uptime() - start
    start = time.uptime()

    module.tps = tps / timeout

    print(timeout, module.tps)
  end
end)

return module
