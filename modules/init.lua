local nu = require "shared/utils/not_utils";
local mp = nu.multiplayer
local logger = require "shared/core/logger";
local ns_events = require "shared/core/ns_events"

if mp.api.server then
  logger:println("I", "Включаем серверную часть мода");
  require "server/init"
end

if mp.api.client then
  logger:println("I", "Включаем клиентскую часть мода");
  require "client/init"
end

ns_events.on("first_tick", function()
  logger:println("I", string.format("NotSurvival is running in %s mode.", mp.mode));
end)
