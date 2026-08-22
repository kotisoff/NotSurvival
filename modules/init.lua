local mp = require "shared/lib/multiplayer";
local logger = require "shared/core/logger";

if mp.api.server then
  logger:println("I", "Initializing server side...");
  require "server/init"
end

if mp.api.client then
  logger:println("I", "Initializing client side...");
  require "client/init"
end

ns_events.on("first_tick", function()
  logger:println("I", string.format("NotSurvival is running in %s mode.", mp.side));
end)
