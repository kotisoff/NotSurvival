local StartSprinting = require "shared/net/messages/StartSprinting";
---@cast StartSprinting neutron.client.messages.Message

local sprinting      = false

---@param state boolean
local function set_sprint(state)
  sprinting = state
  StartSprinting:send({ state = state });
end

ns_events.on("player_tick", function(pid, tps)
  if pid ~= hud.get_player() then return end

  if input.is_active("movement.sprint") and not hud.is_inventory_open() and not hud.is_paused() then
    local x, _, z = player.get_vel(pid)
    local vel = vec2.length({ x, z })

    if sprinting then
      if vel < 3.6 then
        return set_sprint(false)
      end
    elseif vel >= 3.6 then
      return set_sprint(true)
    end
  elseif sprinting then
    set_sprint(false)
  end
end)
