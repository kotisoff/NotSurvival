local constants = require "constants";
local ns_events = require "shared/utils/ns_events"
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

function on_attacked(attacker_eid, attacker_pid)
  ns_events.emit("player_attacked", entity:get_player());
end

function on_render(delta)
  if mp_c then
    speed_limiter.__update(entity);
  end
end
