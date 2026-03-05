local ns_events  = require "shared/core/ns_events"
local net_events = require "shared/network/utils/net_events"
local packets    = net_events.packets;
local bson       = require "shared/utils/bson"

local sprinting  = false

local function start_sprint()
  sprinting = true
  net_events.client.send(packets.player_sprinting, bson.serialize({ true }))
end

local function stop_sprint()
  sprinting = false
  net_events.client.send(packets.player_sprinting, bson.serialize({ false }))
end

ns_events.on(("player_tick"), function(pid, tps)
  if pid ~= hud.get_player() then return end

  if input.is_active("movement.sprint") and not hud.is_inventory_open() and not hud.is_paused() then
    local x, _, z = player.get_vel(pid)
    local vel = vec2.length({ x, z })

    if sprinting then
      if vel >= 3.6 then
        return stop_sprint()
      end
    elseif vel >= 3.6 then
      return start_sprint()
    end
  elseif sprinting then
    stop_sprint()
  end
end)
