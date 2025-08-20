local health          = require "shared/survival/health"
local hunger          = require "shared/survival/hunger"
local death           = require "shared/survival/death"
local system_handlers = require "server/lib/util/system_handlers"

system_handlers.add_ticking_event("ns.damage.starving", function(pid, tps, starving)
  local hunger_lvl = hunger.get_hunger(pid)

  if hunger_lvl <= 0 and not death.get(pid) then
    starving:add(1)
    if starving:get(0) > tps then
      starving:set(0)

      health.damage(pid, 1, { damage_type = "ns.damage.hit", do_knockback = false })
    end
  elseif starving:get() then
    starving:set(nil)
  end
end)
