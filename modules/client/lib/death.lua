local module_gen = require "shared/player/module_gen"

local module = module_gen.cli.create_bool("status", "dead")

local death_overlay = "not_survival:death"
local document = Document.new(death_overlay)

---@param score? int
function module.show_overlay(score)
  if score then
    document.score.text = string.format("Score: [#FFFF00]%d", score)
  end
  hud.show_overlay(death_overlay, false)
end

function module.close_overlay()
  hud.close(death_overlay)
end

return module
