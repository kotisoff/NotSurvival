local ns_events = require "shared/core/ns_events"
local mp = require "shared/utils/not_utils".multiplayer
local player_data = require "shared/player/data/manager"
local net_events = require "shared/network/utils/net_events"
local fall_distance = require "shared/utils/fall_distance"
local movement_controller = require "client/systems/movement_controller"

local tsf = entity.transform
local body = entity.rigidbody
local rig = entity.skeleton

mp.as_server(function(server, mode)
  if not SAVED_DATA.data then
    ARGS = {
      data = player_data.new_base(),
      attributes = player_data.new_attributes(),
      status = player_data.new_status()
    }
  else
    ARGS = SAVED_DATA
  end
end)

function on_save()
  if mp.api.server then
    SAVED_DATA = ARGS
  end
end

function on_grounded(velocity)
  mp.as_client(function(client, mode)
    if fall_distance.calculate_damage(velocity) > 0 then
      net_events.client.send(net_events.packets.player_grounded, client.bson.serialize({ velocity }))
    end
  end)
end

function on_attacked(attacker_eid, attacker_pid)
  ns_events.emit("player_attacked", entity:get_player());
end

function on_render(delta)
  mp.as_client(function(client, mode)
    movement_controller.__update(entity);
  end)
end
