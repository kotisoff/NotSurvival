local data = require "shared/player/data"

local module = {};

local death_overlay = "not_survival:death"
local document = Document.new(death_overlay)

function module.get()
  return data.get_status(hud.get_player(), "dead");
end

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
