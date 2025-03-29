local resource = require "utils/resource_func";
local health = require "server/api/health";
local player_data = require "server/utils/player_data";

local gravity = 22.18;

-- Fall damage.
events.on(resource("grounded"), function(pid, velocity)
  if player_data.get_data(pid).gamemode ~= 0 then return end

  local x, y, z = player.get_pos(pid);

  local water = block.index("base:water");
  if block.get(x, y, z) == water then
    return;
  end;

  local fall_distance = (velocity ^ 2) / (2 * gravity);

  local damage = math.floor(fall_distance) - 3;
  if damage <= 0 then return end;

  health.damage(pid, damage, {
    damage_type = "ns.damage.fall",
    do_knockback = false
  })
end)
