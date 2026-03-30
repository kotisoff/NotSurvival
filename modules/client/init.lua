local ns_events = require "shared/core/ns_events";
local logger = require "shared/lib/logger";
local prefix = require "shared/utils/prefix"
local sync_data = require "shared/net/sync_tools/sync_player_data"
local system_controller = require "client/lib/system_controller"

local require_folder = require "shared/utils/require_folder"

require_folder "client/events/local"
require_folder "client/events/net"

local systems = require_folder "client/systems"

for _, system in pairs(systems) do
  system_controller:register(system);
end

ns_events.on("hud_open", function()
  hud.open_permanent(prefix "survival_hud")

  console.log("[#00ff00]NotSurvival - 0.3.0[#ffffff]")

  system_controller:register_player();
  sync_data.update("data")
  sync_data.update("status")
  sync_data.update("attributes")
end)

ns_events.on("world_quit", function()
  system_controller:register_player();
end)

logger:println("I", "Клиент-сайд тута.")
