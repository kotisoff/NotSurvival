local resource = require "utils/resource_func";
local mp_api = require("mp_api/init")();
local player_data = require "server/utils/player_data";
local health = require "server/api/health"

local tsf = entity.transform
local body = entity.rigidbody
local rig = entity.skeleton

local player_damage = 1;

if mp_api.server then
  ARGS.data = ARGS.data
      or SAVED_DATA.data
      or player_data.new_data();

  ARGS.attributes = ARGS.attributes
      or SAVED_DATA.attributes
      or player_data.new_attributes();

  ARGS.status = ARGS.status
      or SAVED_DATA.status
      or player_data.new_status();
end;

function on_save()
  if mp_api.server then
    SAVED_DATA.data = ARGS.data;
    SAVED_DATA.attributes = ARGS.attributes;
    SAVED_DATA.status = ARGS.status;
  end
end

function on_grounded(velocity)
  if ARGS.pid then
    events.emit(resource("grounded"), ARGS.pid, velocity);
  end
end

function on_attacked(attackerid, pid)
  health.damage(pid, player_damage,
    {
      do_knockback = true,
      source = { player.get_pos(attackerid) },
      attacker = attackerid,
      damage_type = "ns.damage.hit"
    }
  )
end

-- local function first_tick()
--   gamemode.set_player_mode(ARGS.pid, gamemode.get_player_mode(ARGS.pid));
-- end

-- local first_player_tick = true;
-- events.on(resource("player_tick"), function(pid)
--   if pid ~= ARGS.pid then return end;

--   if first_player_tick then
--     first_player_tick = false;
--     first_tick();
--   end

--   -- Check if player variable out of bounds.
--   for key, value in pairs(ARGS.data) do
--     if type(value) ~= "number" then goto continue end;

--     if ARGS.attributes[key] and value > ARGS.attributes[key] then
--       ARGS.data[key] = ARGS.attributes[key];
--     elseif value < 0 then
--       ARGS.data[key] = 0;
--     end

--     ::continue::
--   end
-- end)
