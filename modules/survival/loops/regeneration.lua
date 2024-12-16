local hunger = require("survival/hunger");
local health = require("survival/health");

local regen_tick = {};

local function add_regen(pid, val)
  regen_tick[pid] = (regen_tick[pid] or 1) + (val or 0);
end

local second = 60;
events.on(resource("player_tick"), function(pid)
  local hp = health.get(pid);
  local max = health.get_max(pid);

  local hungerlevel = hunger.get(pid);
  local hungermax = hunger.get_max(pid);

  if hp < max and hungerlevel > hungermax - 2 then
    add_regen(pid, 1);
    if regen_tick[pid] % second == 0 then
      health.heal(pid, 1);
      hunger.consume(pid, 1);
    end
  else
    regen_tick[pid] = 1;
  end
end)
