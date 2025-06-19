local mp = require "utils/not_utils".multiplayer
local resource = require "utils/resource_func"

if mp.api.server then
  require "server/init"
end

if mp.api.client then
  require "client/init"
end

events.on(resource("first_tick"), function()
  print("NotSurvival is running in " .. mp.mode .. " mode.")
end)
