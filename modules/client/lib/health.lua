local data   = require "shared/player/data_manager"

local module = {}

---@return number
function module.get()
  local pid = hud.get_player()
  return data.get_data(pid).health
end

---@return number
function module.get_max()
  local pid = hud.get_player()
  return data.get_attributes(pid).health
end

return module
