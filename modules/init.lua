local nu = require "shared/utils/not_utils";
local mp = nu.multiplayer
local logger = nu.Logger.new("not_survival");

local resource = require "shared/utils/resource_func"

require "tags";

if mp.api.server then
  require "server/init"
end

if mp.api.client then
  require "client/init"
end

events.on(resource("first_tick"), function()
  logger:log("I", "NotSurvival is running in " .. mp.mode .. " mode.")
end)
