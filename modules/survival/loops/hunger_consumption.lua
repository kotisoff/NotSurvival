local api = require "api";
local hunger = api.hunger;
local health = api.health;

local damage_ticks = {};
local staving_ticks = {};

local function add_starv(pid, val)
  staving_ticks[pid] = (staving_ticks[pid] or 1) + (val or 0)
end

local second = 60;
events.on(resource("player_tick"), function(pid)
  if hunger.get(pid) <= 0 then
    damage_ticks[pid] = (damage_ticks[pid] or 0) + 1;
    if damage_ticks[pid] % (second * 3) == 0 then
      health.damage(pid, 1, "from starving");
    end
  else
    damage_ticks[pid] = 0;
  end

  local x, y, z = player.get_vel(pid);
  local vel = math.floor(math.sqrt(x ^ 2 + z ^ 2));

  if vel > 15 then
    add_starv(pid, 5);
  elseif vel >= 3.5 then
    add_starv(pid, 1);
  end

  if (staving_ticks[pid] or 1) % (second * 10) == 0 then
    hunger.consume(pid, 1);
    staving_ticks[pid] = 1;
  else
  end
end)
