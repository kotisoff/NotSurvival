local pack_id = "not_survival"

local resource = require "shared/utils/resource_func";
local mp = require "shared/utils/not_utils".multiplayer
local mp_c, mp_s = mp.api.client, mp.api.server
local player_data = require "shared/player/data"
local packets = require "shared/utils/declarations/packets"
local fall_distance = require "shared/lib/fall_distance"

local tsf = entity.transform
local body = entity.rigidbody
local rig = entity.skeleton

if mp_s then
  if #SAVED_DATA ~= 3 or not SAVED_DATA[1] then
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
  if mp_c then
    if fall_distance.calculate_damage(velocity) > 0 then
      mp_c.events.send(pack_id, packets.player_grounded, mp_c.bson.serialize({ velocity }))
    end
  end
end

function on_attacked(attackerid, pid)
  print("Пиздим.")
  mp_c.events.send(pack_id, packets.player_attacked, mp_c.bson.serialize({ attackerid, pid }))
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
