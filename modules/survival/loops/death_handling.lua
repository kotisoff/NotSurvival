local api = require "api";
local health = api.health;
local variables = api.variables;

local document = Document.new("not_survival:death");

events.on(resource("player_tick"), function(pid)
  local status = variables.get_player_status(pid);

  if variables.get_player_data(pid).gamemode ~= 0 then return end

  if health.get(pid) <= 0 and not status.dead then
    document.reason.text = "Died " .. variables.get_player_damage(pid).type
    status.dead = true;
    hud.show_overlay(resource("death"));
  end
  if status.dead and not hud.is_inventory_open() then
    hud.show_overlay(resource("death"))
  end
end)
