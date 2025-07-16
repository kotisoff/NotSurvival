local data = require "shared/player/data"

local module = {}

---@type ns.attributefield
local field = "oxygen";

---@return number
function module.get()
  local pid = hud.get_player()
  return data.get_data(pid, field)
end

---@return number
function module.get_max()
  local pid = hud.get_player()
  return data.get_attributes(pid, field)
end

return module
