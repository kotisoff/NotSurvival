local ns_events = require "shared/core/ns_events";
local system_controller = require "server/lib/system_controller"
local loaders = require "shared/lib/loaders/main";
local storage = require "server/data_storage";
local logger = require "shared/core/logger";

require "shared/player/data/manager"

ns_events.on("first_tick", function()
  loaders.reload();
  storage.load();
end)

local require_folder = require "shared/utils/require_folder"
require_folder "server/events"
local systems = require_folder "server/systems"

for _, system in pairs(systems) do
  system_controller:register(system);
end

require "server/commands";

logger:println("I", "Server side initialized.")
