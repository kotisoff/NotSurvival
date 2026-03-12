local health          = require "shared/player/stats/health"
local death           = require "shared/player/stats/death"
local oxygen          = require "shared/player/stats/oxygen"
local system_instance = require "shared/lib/system_instance"
local Counter         = require "shared/lib/Counter"

local function is_under_block(pid)
  local x, y, z = player.get_pos(pid);
  local blockid = block.get(x, y + 1, z);
  return blockid ~= 0, blockid;
end

local water = block.index("base:water")

local is_under_water = function(pid)
  local under_block, blockid = is_under_block(pid)
  return under_block and blockid == water
end

local Drowning_system = system_instance.new("ns.damage.drowning");

function Drowning_system:on_player_remove(id)
  Counter.get_or_create(id, self.name):destroy();
end

function Drowning_system:should_update(id)
  return not death.is_invulnerable(id)
end

function Drowning_system:update(id, tps)
  local drown = Counter.get_or_create(id, self.name);
  local under_water = is_under_water(id)

  if under_water then
    drown:add(1)
  else
    drown:set(0)
  end

  if under_water and not death.get(id) then
    if drown:get(0) > tps then
      drown:set(0)

      oxygen.add(id, -1)
      if oxygen.get(id) <= 0 then
        health.damage(id, 2, { damage_type = "ns.damage.drowning", do_knockback = false })
      end
    end
  elseif not under_water and oxygen.get(id) < oxygen.get_max(id) then
    local regen = Counter.get_or_create(id, self.name .. ".regen");
    regen:add(1)
    if regen:get(0) > tps / 2 then
      regen:set(0)
      oxygen.add(id, 1)
    end
  end
end

return Drowning_system;
