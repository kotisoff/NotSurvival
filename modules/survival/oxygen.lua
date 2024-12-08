local PACK_ID = "not_survival"; function resource(name) return PACK_ID .. ":" .. name end

require("variables");

oxygen = {};

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
  local current = oxygen.get(pid);
  variables.get_player_data(pid).oxygen = current + amount;
end

function oxygen.sub(pid, amount)
  local current = oxygen.get(pid);
  variables.get_player_data(pid).oxygen = current - amount;
end

return oxygen;
