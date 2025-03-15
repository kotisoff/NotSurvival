local resource = require "utility/resource_func"
local api = require "api";
local hunger = api.survival.hunger;
local health = api.survival.health;

local regen_tick = {};

local function add_regen(pid, val)
  regen_tick[pid] = (regen_tick[pid] or 1) + (val or 0);
end

events.on(resource("player_tick"), function(pid, tps)
  local hp = health.get(pid);
  local max = health.get_max(pid);

  local hungerlevel = hunger.get(pid);
  local hungermax = hunger.get_max(pid);

  if hp < max and hungerlevel > hungermax - 2 then
    add_regen(pid, 1);
    if regen_tick[pid] % tps == 0 then
      health.heal(pid, 1);
      hunger.consume(pid, 1);
    end
  else
    regen_tick[pid] = 1;
  end
end)
