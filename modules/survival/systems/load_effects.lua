local resource = require "utility/resource_func"
local api = require "api";
local variables = api.player.variables;
local effects = api.survival.effects;

events.on(resource("hud_open"), function(pid)
  local status = variables.get_player_status(pid);
  status.effects = status.effects or {};

  for _, value in ipairs(status.effects) do
    effects.give(pid, value.identifier, value.level, value.time_left, false);
  end
end)
