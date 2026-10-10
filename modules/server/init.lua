local stats_loader = require "shared/player/data/stats_loader"
local system_controller = require "server/lib/system_controller"
local loaders = require "shared/lib/loaders/main";
local storage = require "shared/core/data_storage";

ns_events.on("first_tick", function()
  stats_loader.reload();
  loaders.reload();
  storage.load();
end)

local require_folder = require "shared/utils/require_folder"

require_folder "server/events/internal"
require_folder "server/events/local"
require_folder "server/events/net"

local systems = require_folder "server/systems"

for _, system in pairs(systems) do
  system_controller:register(system);
end

local filters = require_folder "server/systems/filters"

for name, filter in pairs(filters) do
  system_controller:register_filter(name, filter);
end

require "server/commands";

logger:println("I", "Server side initialized.")
