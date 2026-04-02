local system_instance = require "shared/lib/system_instance"
local death           = require "shared/player/stats/death"

---@type ns.ecs.system | { hit_timer: int }
local system          = system_instance.new("ns.system.death_handling")
system.hit_timer      = 0;

function system:init()
  local prev_hand_controller = hud.hand_controller or hud.default_hand_controller
  hud.hand_controller = function()
    if prev_hand_controller then
      prev_hand_controller()
    end

    local skeleton = gfx.skeletons
    local pid = hud.get_player()
    local invid, slot = player.get_inventory(pid)
    local itemid = inventory.get(invid, slot)

    local cam = cameras.get("core:first-person")
    local bone = skeleton.index("hand", "item")

    local matrix = skeleton.get_matrix("hand", bone)
    if self.hit_timer > 0.0 then
      local timer = self.hit_timer - 0.0
      matrix = mat4.rotate(matrix, { 0, 0, 1 }, (timer) * 120)
      matrix = mat4.translate(matrix, { -timer, timer * 0.5, 0 })
    end
    skeleton.set_matrix("hand", bone, matrix)
  end
end

function system:should_update(pid)
  return not death:get()
end

function system:update()
  if self.hit_timer > 0 then
    self.hit_timer = self.hit_timer - time.delta() * 5
  else
    self.hit_timer = 0.0
  end
end

return system;

--[[
  Credits to: MihailRis
    for original script of hand animation
]]
