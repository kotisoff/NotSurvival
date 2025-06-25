local data = require "shared/player/data"

local function is_survival(pid)
  return data and data.get_status(pid, "gamemode") == 0
end
local tmp

tmp = player.set_flight
player.set_flight = function(playerid, flag)
  if not is_survival(playerid) then
    tmp(playerid, flag)
  end
end

tmp = player.set_noclip
player.set_noclip = function(playerid, flag)
  if not is_survival(playerid) then
    tmp(playerid, flag)
  end
end
