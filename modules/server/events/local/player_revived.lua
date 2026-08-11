local logger    = require "shared/core/logger";
local ns_events = require "shared/core/ns_events";

local health    = require "shared/player/stats/health"
local hunger    = require "shared/player/stats/hunger"
local oxygen    = require "shared/player/stats/oxygen"

---@param pid int
ns_events.on("player_revived", function(pid)
  health.full(pid);
  hunger.full(pid);
  oxygen.full(pid);

  logger:println("I", string.format("Revived %s(%s)", player.get_name(pid), pid));
end)
