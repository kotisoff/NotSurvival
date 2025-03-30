local mp_api = require("mp_api/init")();
local player_data = require "client/utils/player_data";
local resource = require "utils/resource_func";
local vector3 = require "core:vector3";

local module = {};

module.values = {
  speed_limit = 7
};

events.on(resource("world_tick"), function()
  --if not rules.get("ns-control-movement") then return end;

  local pid = hud.get_player();
  local data = player_data.data;
  if data.gamemode == 0 then
    local vel = vector3(player.get_vel(pid));
    local speed = vec3.length({ vel.x, 0, vel.z });
    if speed > module.values.speed_limit then
      local new_vel = vel:norm() * module.values;
      player.set_vel(pid, new_vel.x, new_vel.y, new_vel.z);
    end

    player.set_noclip(pid, false);
    player.set_flight(pid, false);
  end
end)
