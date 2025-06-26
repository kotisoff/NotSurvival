local data = require "shared/player/data"

local module = {}

---@return number
function module.get()
  local pid = hud.get_player()
  return data.get_data(pid, "oxygen")
end

---@return number
function module.get_max()
  local pid = hud.get_player()
  return data.get_attributes(pid, "oxygen")
end

return module
