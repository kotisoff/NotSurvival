local nu = require "shared/utils/not_utils";
local mp = nu.multiplayer
local logger = nu.Logger.new("not_survival");

logger:log("I", "Клиент-сайд тута.")

local resource = require "shared/utils/resource_func"

-- ========================systems==========================
local data = require "shared/player/data_manager"

local require_folder = require "shared/utils/require_folder"

require_folder "client/event"
require_folder "client/system"

-- =========================================================

events.on(resource("hud_open"), function()
  hud.open_permanent(resource("survival_hud"))

  console.log("[#00ff00]NotSurvival - 0.3.0-mp-preview-1[#ffffff]")
  console.log(
    "[#ffff00]Используйте мод с осторожностью, поскольку из-за постоянных обновлений многие механики могут менятся от версии к версии[#ffffff]")
  console.log("[#aeaeae]Ой как я надеюсь что ничё не ёбнет за время эксплуатации мода[#ffffff]")

  data.update("data")
  data.update("status")
  data.update("attributes")
end)
