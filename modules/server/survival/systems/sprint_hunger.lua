local resource = require "utility/resource_func"
local api = require "api";
local hunger = api.survival.hunger;
local staving_ticks = {};

local function add_starv(pid, val)
  staving_ticks[pid] = (staving_ticks[pid] or 1) + (val or 0)
end

events.on(resource("player_tick"), function(pid, tps)
  local x, y, z = player.get_vel(pid);
  local vel = math.floor(math.sqrt(x ^ 2 + z ^ 2));

  if vel > 15 then
    add_starv(pid, 5);
  elseif vel >= 3.5 then
    add_starv(pid, 1);
  end

  if (staving_ticks[pid] or 1) % (tps * 10) == 0 then
    hunger.consume(pid, 1);
    staving_ticks[pid] = 1;
  else
  end
end)
