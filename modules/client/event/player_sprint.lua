local ns_events = require "shared/core/ns_events"
local mp        = require "shared/utils/not_utils".multiplayer.api.client
local packets   = require "shared/utils/declarations/packets"
local resource  = require "shared/utils/resource_func"

local packid    = "not_survival"

local sprinting = false

local function start_sprint()
  sprinting = true
  mp.events.send(packid, packets.player_sprinting, mp.bson.serialize({ true }))
end

local function stop_sprint()
  sprinting = false
  mp.events.send(packid, packets.player_sprinting, mp.bson.serialize({ false }))
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
