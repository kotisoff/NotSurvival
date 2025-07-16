local data = require "shared/player/data"

local module = {}

---@type ns.attributefield, ns.attributefield
local f_h, f_s = "hunger", "saturation";

function module.get_hunger()
  local pid = hud.get_player()
  return data.get_data(pid, f_h)
end

function module.get_max_hunger()
  local pid = hud.get_player()
  return data.get_attributes(pid, f_h)
end

function module.get_saturation()
  local pid = hud.get_player()
  return data.get_data(pid, f_s)
end

function module.get_max_saturation()
  local pid = hud.get_player()
  return data.get_attributes(pid, f_s)
end

return module
