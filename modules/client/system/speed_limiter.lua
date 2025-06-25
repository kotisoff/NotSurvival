local data = require "shared/player/data"
local resource = require "shared/utils/resource_func"

local module = {}

local default_speed = 7
local limit = default_speed

events.on(resource("player_tick"), function(pid, tps)
  if hud.get_player() ~= pid then return end

  local gm = data.get_status(pid, "gamemode")
  if gm == 0 then
    local x, y, z, _ = player.get_vel(pid) -- _ for nil
    local speed = vec2.length({ x, z })

    if speed > limit then
      x, _, z = unpack(vec3.mul(vec3.normalize({ x, y, z }), limit))
      player.set_vel(pid, x, y, z)
    end

    player.set_noclip(pid, false)
    player.set_flight(pid, false)
  end
end)

---@param value? number
---@return number
function module.set_limit(value)
  limit = value or default_speed
  return limit
end

function module.get_limit()
  return limit or module.set_limit(default_speed)
end

return module
