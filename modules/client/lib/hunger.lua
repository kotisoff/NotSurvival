local data = require "shared/player/data"

local module = {} -- мда.

function module.get_hunger()
  local pid = hud.get_player()
  return data.get_data(pid, "hunger")
end

function module.get_max_hunger()
  local pid = hud.get_player()
  return data.get_attributes(pid, "hunger")
end

function module.get_saturation()
  local pid = hud.get_player()
  return data.get_data(pid, "saturation")
end

function module.get_max_saturation()
  local pid = hud.get_player()
  return data.get_attributes(pid, "saturation")
end

return module
