local PACK_ID = PACK_ID or "not_survival"; local function resource(name) return PACK_ID .. ":" .. name end;

local variables = require "api".variables;

gamemode = {};

gamemode.modes = {};

function gamemode.get_gamemode(name_or_key)
  for key, value in pairs(gamemode.modes) do
    if
        tostring(key - 1) == tostring(name_or_key)
        or value.name == name_or_key
    then
      return key - 1, value
    end
  end
  return nil;
end

function gamemode.register(mode, func)
  table.insert(gamemode.modes, {
    name = mode,
    handler = func
  });
end

function gamemode.set_player_mode(pid, name_or_key)
  local key, mode = gamemode.get_gamemode(name_or_key);
  if not mode then return false end;
  mode.handler(pid);

  local playerdata = variables.get_player_data(pid);
  playerdata.gamemode = key;

  events.emit(resource("change_gamemode"), key);

  return true;
end

function gamemode.get_player_mode(pid)
  return variables.get_player_data(pid).gamemode;
end

-- Basic gamemodes

local creativeRules = {
  "allow-fast-interaction",
  "allow-debug-cheats",
  "allow-cheat-movement",
  "allow-noclip",
  "allow-flight",
  "allow-content-access"
}

function gamemode.set_creative_rules(state)
  for _, value in pairs(creativeRules) do
    rules.set(value, state);
  end
end

function gamemode.set_creative_player_states(pid, state)
  player.set_instant_destruction(pid, state)
  player.set_infinite_items(pid, state)
  player.set_flight(pid, state)
  player.set_noclip(pid, state)
end

gamemode.register("survival", function(pid)
  hud.open_permanent(resource("survival_hud"));

  gamemode.set_creative_rules(false);
  gamemode.set_creative_player_states(pid, false);
end)

gamemode.register("creative", function(pid)
  hud.close(resource("survival_hud"));

  gamemode.set_creative_rules(true);
  gamemode.set_creative_player_states(pid, true);
end)

return gamemode;
