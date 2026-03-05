local ns_events = require "shared/core/ns_events";
local logger = require "shared/lib/logger";
local prefix = require "shared/utils/prefix"
local sync_data = require "shared/network/sync_tools/player_data"

logger:println("I", "Клиент-сайд тута.")

-- ========================systems==========================
local data = require "shared/player/data/manager"

local require_folder = require "shared/utils/require_folder"

require_folder "client/event"
require_folder "client/systems"

-- =========================================================

ns_events.on("hud_open", function()
  hud.open_permanent(prefix "survival_hud")

  console.log("[#00ff00]NotSurvival - 0.3.0[#ffffff]")

  sync_data.update("data")
  sync_data.update("status")
  sync_data.update("attributes")
end)
