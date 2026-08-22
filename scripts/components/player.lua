local ns_events = require "shared/core/ns_events"
local mp = require "shared/lib/not_utils".multiplayer
local player_data = require "shared/player/data/manager"
local movement_controller = require "client/systems/movement_controller"

local tsf = entity.transform
local rig = entity.skeleton

-- mp.as_server(function(server, mode)
--   if not SAVED_DATA.data then
--     ARGS = {
--       data = player_data.new_base(),
--       attributes = player_data.new_attributes(),
--       status = player_data.new_status()
--     }
--   else
--     ARGS = SAVED_DATA
--   end
-- end)

-- function on_save()
--   if mp.api.server then
--     SAVED_DATA = ARGS
--   end
-- end

function on_attacked(attacker_eid, attacker_pid)
  mp.as_server(function(server, mode)
    local victim_pid = entity:get_player();
    ns_events.emit("player_attacked", victim_pid, attacker_pid, attacker_eid);
  end)
end

function on_render(delta)
  mp.as_client(function(client, mode)
    movement_controller.__update(entity);
  end)
end
