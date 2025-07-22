local data = require "shared/player/data"

local function is_survival(pid)
  return data.get_status(pid, "gamemode") == 0
end

local set_flight = player.set_flight
player.set_flight = function(playerid, flag)
  if not pack.is_installed("not_survival") or not is_survival(playerid) then
    set_flight(playerid, flag)
  end
end

local set_noclip = player.set_noclip
player.set_noclip = function(playerid, flag)
  if not pack.is_installed("not_survival") or not is_survival(playerid) then
    set_noclip(playerid, flag)
  end
end
