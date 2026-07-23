local resource = require "utility/resource_func"
local api = require "api";
local hunger = api.survival.hunger;
local health = api.survival.health;
local death = api.survival.death;

local damage_ticks = {};

events.on(resource("player_tick"), function(pid, tps)
  if death.is_invulnerable(pid) then return end;

  if hunger.get(pid) <= 0 then
    damage_ticks[pid] = (damage_ticks[pid] or 0) + 1;
    if damage_ticks[pid] % (tps * 3) == 0 then
      health.damage(pid, 1, "from starving");
    end
  else
    damage_ticks[pid] = 0;
  end
end)
