print("Клиент-сайд тута.")

local resource = require "utils/resource_func"
local data = require "shared/player/data"

local require_folder = require "utils/require_folder"
require_folder "client/event"

events.on(resource("hud_open"), function()
  print("Открываем худ")
  hud.open_permanent(resource("survival_hud"))

  console.log("[#00ff00]NotSurvival - 0.3.0-mp-preview-1[#ffffff]")
  console.log(
    "[#ffff00]Используйте мод с осторожностью, поскольку из-за постоянных обновлений многие механики могут менятся от версии к версии[#ffffff]")
  console.log("[#aeaeae]Ой как я надеюсь что ничё не ёбнет за время эксплуатации мода[#ffffff]")

  local username = player.get_name(hud.get_player())
  data.update(username, "data")
  data.update(username, "status")
  data.update(username, "attributes")
end)
