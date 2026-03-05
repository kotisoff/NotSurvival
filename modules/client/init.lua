local ns_events = require "shared/core/ns_events";
local logger = require "shared/lib/logger";
local prefix = require "shared/utils/prefix"

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

  data.update("data")
  data.update("status")
  data.update("attributes")
end)
