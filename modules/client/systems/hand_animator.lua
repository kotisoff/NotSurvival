local system_instance = require "shared/lib/system_instance"
local death           = require "shared/player/stats/death"

---@type ns.ecs.system
local system          = system_instance.new("ns.system.death_handling")

function system:init()
  local prev_hand_controller = hud.hand_controller or hud.default_hand_controller
  hud.hand_controller = function()
    if prev_hand_controller then
      prev_hand_controller()
    end
  end
end

function system:should_update(pid)
  return not death:get()
end

function system:update()
end

return system;
