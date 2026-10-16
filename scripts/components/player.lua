local ns_events           = require "shared/core/ns_events"
local mp                  = require "shared/lib/multiplayer"
local movement_controller = require "client/systems/movement_controller"

local tsf                 = entity.transform
local body                = entity.rigidbody
local rig                 = entity.skeleton

function on_attacked(attacker_eid, attacker_pid)
  if mp.side == "server" then
    local victim_pid = entity:get_player();
    ns_events.emit("player_attacked", victim_pid, attacker_pid, attacker_eid);
  end
end

function on_render(delta)
  if mp.side == "client" then
    movement_controller.__update(entity);
  end
end
