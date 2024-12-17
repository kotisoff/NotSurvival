local PACK_ID = "not_survival"; function resource(name) return PACK_ID .. ":" .. name end

local function is_flight(pid)
  return player.is_flight(pid) or player.is_noclip(pid)
end

local water = block.index("base:water");


local function player_pos(pid)
  local x, y, z = player.get_pos(pid);
  x = x - 1;
  return x, y, z;
end

local function is_underwater(pid)
  local x, y, z = player_pos(pid);
  return block.get(x, y - 0.3, z) == water or block.get(x, y + 1, z) == water
end

local function head_underwater(pid)
  local x, y, z = player_pos(pid);
  return block.get(x, y + 0.8, z) == water;
end

local function body_underwater(pid)
  return block.get(player_pos(pid)) == water;
end

local underwater_sounds = "not_survival/ambient/underwater/"
local function play_underwater_sound(pid, name)
  local x, y, z = player.get_pos(pid);

  audio.play_sound(underwater_sounds .. name .. math.random(3),
    x, y - 0.5, z, 0.7, math.rand(0.9, 1.2), "regular"
  )
end

local function play_splash_sound(pid)
  local x, y, z = player.get_pos(pid);

  audio.play_sound("not_survival/random/splash",
    x, y - 0.5, z, 1, math.rand(0.9, 1.2), "regular"
  )
end

local swim_speed = 3.5;

local under_water = {};
local on_water = {};

events.on(resource("player_tick"), function(pid, tps)
  if is_flight(pid) then return end;

  if is_underwater(pid) then
    local x, y, z = player.get_vel(pid)

    if vec3.length({ x, 0, z }) > swim_speed then
      x, _, z = unpack(vec3.mul(vec3.normalize({ x, y, z }), swim_speed));
    end

    if y < 0 then y = y * 0.6 end;
    if y < -1.8 then y = math.abs(y) * -0.9 end

    --Sounds

    if head_underwater(pid) then
      if not under_water[pid] then
        under_water[pid] = true;
        play_underwater_sound(pid, "enter");
      end
    elseif under_water[pid] then
      under_water[pid] = false;
      play_underwater_sound(pid, "exit");
    end

    if not on_water[pid] then
      on_water[pid] = true;
      play_splash_sound(pid);
    end

    -- Movement under water

    if not hud.is_inventory_open() then
      if input.is_active("movement.jump") then
        y = 3;
        if not body_underwater(pid) then
          y = 6;
        end
      end

      if input.is_active("movement.crouch") then
        y = -3;
      end
    end

    player.set_vel(pid, x, y, z);
  else
    on_water[pid] = false;
    under_water[pid] = false;
  end
end)
