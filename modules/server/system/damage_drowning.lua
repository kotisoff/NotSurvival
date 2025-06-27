local health          = require "server/lib/health"
local death           = require "server/lib/death"
local oxygen          = require "server/lib/oxygen"
local system_handlers = require "server/lib/util/system_handlers"

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

system_handlers.set_ticking_event("ns.drown", function(pid, tps, drown, get_ticker)
  local under_water = is_under_water(pid)

  if under_water then
    drown:add(1)
  else
    drown:set(0)
  end

  if under_water and not death.get(pid) and oxygen.get(pid) > 0 and drown:get(0) > tps * 2 then
    drown:set(0)

    oxygen.add(pid, -1)
    if oxygen.get(pid) <= 0 then
      health.damage(pid, 2, { damage_type = "ns.damage.drown", do_knockback = false })
    end
  elseif not under_water and oxygen.get(pid) < oxygen.get_max(pid) then
    local regen = get_ticker(pid, "ns.drown.regen")
    regen:add(1)
    if regen:get(0) > tps then
      regen:set(0)
      oxygen.add(pid, 1)
    end
  end
end)
