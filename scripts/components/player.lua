local constants = require "constants";
local pack_id = constants.pack_id;

local mp = require "shared/utils/not_utils".multiplayer
local mp_c, mp_s = mp.api.client, mp.api.server
local player_data = require "shared/player/data_manager"
local packets = require "shared/utils/declarations/packets"
local fall_distance = require "shared/lib/fall_distance"
local speed_limiter = require "client/system/movement_controller";

local tsf = entity.transform
local body = entity.rigidbody
local rig = entity.skeleton

if mp_s then
  if not SAVED_DATA.data then
    ARGS = player_data.new_player_data()
  else
    ARGS = SAVED_DATA
  end
end;

function on_save()
  if mp.api.server then
    SAVED_DATA = ARGS
  end
end

function on_grounded(velocity)
  if mp_c and entity:get_player() == hud.get_player() then
    if fall_distance.calculate_damage(velocity) > 0 then
      mp_c.events.send(pack_id, packets.player_grounded, mp_c.bson.serialize({ velocity }))
    end
  end
end

function on_attacked(attacker, attacker_pid)
  local pid = entity:get_player()
  if mp_c and attacker_pid ~= pid then
    mp_c.events.send(pack_id, packets.player_attacked, mp_c.bson.serialize({ attacker_pid }))
  end
end

function on_render(delta)
  if mp_c then
    speed_limiter.__update(entity);
  end
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
