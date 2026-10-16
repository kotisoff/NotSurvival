local ns_events = require "shared/core/ns_events"

local tsf = entity.transform
local body = entity.rigidbody

local max_y = 0

function on_fall()
  local pos = tsf:get_pos()
  max_y = pos[2]
end

function on_physics_update(delta)
  if body:is_grounded() then
    return
  end

  local y = tsf:get_pos()[2]
  max_y = math.max(max_y, y);
end

function on_grounded(force)
  local y = tsf:get_pos()[2]
  local distance = (max_y or y) - y

  max_y = 0

  if distance > 0 then
    ns_events.emit("player_grounded", entity:get_player(), distance)
  end
end
