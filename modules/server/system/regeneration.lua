local health          = require "server/lib/health"
local hunger          = require "server/lib/hunger"
local death           = require "server/lib/death"
local system_handlers = require "server/lib/util/system_handlers"

system_handlers.set_ticking_event("ns.regeneration", function(pid, tps, regen)
  local hp = health.get(pid)
  local max_hp = health.get_max(pid)

  local hunger_lvl = hunger.get_hunger(pid)
  local max_hunger = hunger.get_max_hunger(pid)

  if hp < max_hp and hunger_lvl > max_hunger - 2 and not death.get(pid) then
    regen:add(1)
    if regen:get(0) > tps then
      regen:set(1)

      health.add(pid, 1)
      hunger.consume(pid, 1)
    end
  elseif regen:get() then
    regen:set(nil)
  end
end)
