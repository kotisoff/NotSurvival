---@diagnostic disable: undefined-field

local resource = require "utility/resource_func"
local variables = require "player/variables";

local movement = {
  speed_limit = 7
};

movement.defaults = table.copy(movement);

function movement.set_speed_limit(speed)
  speed = speed or movement.defaults.speed_limit;
  movement.speed_limit = speed;
end

events.on(resource("player_tick"), function(pid)
  if not rules.get("ns-control-movement") then return end;

  local playerdata = variables.get_player_data(pid);
  if playerdata.gamemode == 0 then
    local x, y, z = player.get_vel(pid);

    local speed = vec3.length({ x, 0, z });
    if speed > movement.speed_limit then
      local vel = { x, y, z };

      local nx, ny, nz = unpack(vec3.mul(vec3.normalize(vel), movement.speed_limit));

      player.set_vel(pid, nx, y, nz);
    end

    player.set_noclip(0, false);
    player.set_flight(0, false);
  end
end)

return movement
