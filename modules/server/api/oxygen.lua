local variables = require "player/variables";

local oxygen = {};

function oxygen.get(pid)
  return variables.get_player_data(pid).oxygen;
end

function oxygen.get_max(pid)
  return variables.get_player_attributes(pid).oxygen;
end

function oxygen.set(pid, amount)
  variables.get_player_data(pid).oxygen = amount;
end

-- Fill player oxygen to his max.
function oxygen.full(pid)
  oxygen.set(pid, variables.get_player_attributes(pid).oxygen)
end

function oxygen.add(pid, amount)
  local playerdata = variables.get_player_data(pid);
  local max = oxygen.get_max(pid);

  ---@diagnostic disable-next-line: undefined-field
  playerdata.oxygen = math.clamp(playerdata.oxygen + amount, 0, max);
end

function oxygen.sub(pid, amount)
  local current = oxygen.get(pid);
  variables.get_player_data(pid).oxygen = current - amount;
end

return oxygen;
