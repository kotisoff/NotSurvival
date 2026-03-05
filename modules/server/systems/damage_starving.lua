local health          = require "shared/survival/health"
local hunger          = require "shared/survival/hunger"
local death           = require "shared/survival/death"
local system_instance = require "shared/lib/system_instance"
local Counter         = require "shared/lib/Counter"

local Starving_system = system_instance.new("ns.damage.starving");

function Starving_system:on_entity_remove(id)
  Counter.get_or_create(id, self.name):destroy();
end

function Starving_system:should_update(id)
  return not death.is_invulnerable(id)
end

function Starving_system:update(pid, tps)
  local starving = Counter.get_or_create(pid, self.name);
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
end

return Starving_system
