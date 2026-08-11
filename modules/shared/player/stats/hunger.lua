local mp         = require "shared/utils/not_utils".multiplayer;
local Stat       = require "shared/player/stats/Stat"

local hunger     = Stat("hunger");
local saturation = Stat("saturation");

---@class ns.stat.hunger
local module     = {}

-- ========================shared===========================

---@param pid? int
function module.get_hunger(pid)
  return hunger.get(pid)
end;

---@param pid? int
function module.get_max_hunger(pid)
  return hunger.get_max(pid)
end;

---@param pid? int
function module.get_saturation(pid)
  return saturation.get(pid)
end;

---@param pid? int
function module.get_max_saturation(pid)
  return saturation.get_max(pid)
end;

-- ========================server===========================

mp.as_server(function(server, mode)
  ---Server side only
  ---@param pid int
  ---@param value number
  function module.set_hunger(pid, value)
    hunger.set(pid, value)
  end

  ---Server side only
  ---@param pid int
  ---@param value number
  function module.set_saturation(pid, value)
    saturation.set(pid, value);
  end

  ---Server side only
  ---@param pid int
  function module.full(pid)
    hunger.full(pid);
    saturation.full(pid);
  end

  ---Server side only
  ---@param pid int
  ---@param hunger_amount? number Default: 0
  ---@param saturation_amount? number Default: 0
  function module.add(pid, hunger_amount, saturation_amount)
    hunger_amount = hunger_amount ~= nil and hunger_amount or 0;
    saturation_amount = saturation_amount ~= nil and saturation_amount or 0;

    if hunger_amount ~= 0 then
      local h = hunger.get(pid) + hunger_amount;
      hunger.set(pid, h)
    end
    if saturation_amount ~= 0 then
      local s = saturation.get(pid) + saturation_amount
      saturation.set(pid, s)
    end
  end

  ---Server side only.
  ---@param pid int
  ---@param amount number
  function module.consume(pid, amount)
    local sat = saturation.get(pid) - amount;

    if sat < 0 then
      saturation.set(pid, 0);

      local consumed = math.ceil(math.abs(sat) / hunger.get_max(pid))
      if consumed < 1 then consumed = 1 end

      module.add(pid, -consumed)
    else
      module.set_saturation(pid, sat)
    end
  end
end)

return module
