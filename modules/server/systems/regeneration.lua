local health              = require "shared/player/stats/health"
local hunger              = require "shared/player/stats/hunger"
local death               = require "shared/player/stats/death"
local system_instance     = require "shared/lib/system_instance"
local Counter             = require "shared/lib/Counter"

local Regeneration_system = system_instance.new("ns.system.regeneration");

function Regeneration_system:on_player_remove(id)
  Counter.get_or_create(id, self.name):destroy();
end

function Regeneration_system:should_update(id)
  return not death.is_invulnerable(id)
end

function Regeneration_system:update(pid, tps)
  local regen = Counter.get_or_create(pid, self.name);

  local hp = health.get(pid)
  local max_hp = health.get_max(pid)

  local hunger_lvl = hunger.get_hunger(pid)
  local max_hunger = hunger.get_max_hunger(pid)

  if hp < max_hp and hunger_lvl > max_hunger - 2 and not death.get(pid) then
    regen:add(1)

    local interval = 0.5
    if hunger.get_saturation(pid) <= 0 then
      interval = 4
    end

    if regen:get(0) > tps * interval then
      regen:set(0)

      health.add(pid, 1)
      hunger.consume(pid, 1)
    end
  elseif regen:get() then
    regen:set(nil)
  end
end

return Regeneration_system;
