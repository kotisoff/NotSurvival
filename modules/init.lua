local nu = require "shared/lib/not_utils";
local mp = nu.multiplayer
local logger = require "shared/core/logger";
local ns_events = require "shared/core/ns_events"

if mp.api.server then
  logger:println("I", "Initializing server side...");
  require "server/init"
end

if mp.api.client then
  logger:println("I", "Initializing server side...");
  require "client/init"
end

ns_events.on("first_tick", function()
  logger:println("I", string.format("NotSurvival is running in %s mode.", mp.mode));
end)
