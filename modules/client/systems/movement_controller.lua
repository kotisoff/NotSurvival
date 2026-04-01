local data = require "shared/player/data/manager"
local allow_cheats = require "client/hooks/allow_cheats"

local module = {}

local defaults = {
  speed_in_air = 6.5,
  speed_on_ground = 5.5,
}

local limits = {
  speed_in_air = defaults.speed_in_air,
  speed_on_ground = defaults.speed_on_ground
}

---@alias ns.movement_controller.keys "speed_in_air" | "speed_on_ground" | str

---@param key ns.movement_controller.keys
---@param value? number
---@return number
function module.set_limit(key, value)
  if not limits[key] then return limits[key] end;
  limits[key] = value or defaults[key];
  return limits[key];
end

---@param key ns.movement_controller.keys
function module.get_limit(key)
  return limits[key] or module.set_limit(key, defaults[key]);
end

---@param entity voxelcore.class.entity
function module.__update(entity)
  -- TODO: unlock function.
  if true then return end;

  local pid = entity:get_player();
  if not pid or hud.get_player() ~= pid then return end

  local gm = data.get_status(pid).gamemode
  if gm == 0 then
    local x, y, z, _ = player.get_vel(pid) -- _ for nil
    local speed = vec2.length({ x, z })

    local limit = entity.rigidbody:is_grounded()
        and limits.speed_on_ground
        or limits.speed_in_air;

    if speed > limit or player.is_flight(pid) then
      x, _, z = unpack(vec3.mul(vec3.normalize({ x, y, z }), limit));
      player.set_vel(pid, x, y, z);

      player.set_noclip(pid, false);
      player.set_flight(pid, false);

      allow_cheats(false);
    end
  end
end

return module
