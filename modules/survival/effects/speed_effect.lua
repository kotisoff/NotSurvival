local api = require "api";
local movement = api.player.movement;
local Registry = api.registry;
local Effect = require "utility/base_effect";

local SpeedEffect = Effect.new("not_survival:speed");

local function move(pid, speed, add_yaw)
  local vel = { player.get_vel(pid) };
  debug.print(vel);
  local yaw = player.get_rot(pid);

  local rad = (yaw + (add_yaw or 0)) * math.pi / 180;

  local vel2 = {
    speed * -math.sin(rad),
    0,
    speed * -math.cos(rad)
  }

  vec3.add(vel, vel2);

  player.set_vel(pid, unpack(vel));
end

local movements = {
  ["movement.forward"] = move,
  ["movement.left"] = function(pid, speed) move(pid, speed, 90) end,
  ["movement.right"] = function(pid, speed) move(pid, speed, -90) end,
  ["movement.back"] = function(pid, speed) move(pid, speed, 180) end
}

SpeedEffect.on_applied = function(self, pid, level, duration)
  print(3 * level);
  movement.set_speed_limit(3 * level);
end

SpeedEffect.on_removed = function(self, pid)
  movement.set_speed_limit()
end

SpeedEffect.tick = function(self, pid, level, duration, time_passed)
  local local_player = hud.get_player();
  if not pid == local_player then return end;

  for key, func in pairs(movements) do
    if (input.is_active(key)) then
      func(pid, 3 * level);
    end
  end
end

-- Пока нахуй, ибо не робит
--Registry:register(Registry.TYPES.EFFECTS, SpeedEffect.identifier, SpeedEffect);
