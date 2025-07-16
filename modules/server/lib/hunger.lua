local data          = require "shared/player/data"
local module_utils  = require "server/lib/util/module_utils"

local cat, f_h, f_s = "data", "hunger", "saturation";

local module        = {} -- эту хуету через генератор оптимизировать также вообще не вариант.

function module.get_hunger(pid)
  return data.get_data(pid, f_h)
end

function module.get_max_hunger(pid)
  return data.get_attributes(pid, f_h)
end

function module.get_saturation(pid)
  return data.get_data(pid, f_s)
end

function module.get_max_saturation(pid)
  return data.get_attributes(pid, f_s)
end

function module.set_hunger(pid, amount)
  local max = module.get_max_hunger(pid)
  local value = math.clamp(amount, 0, max)

  data.set_field(pid, cat, f_h, value)
  module_utils.update(pid, cat, f_h, value)
end

function module.set_saturation(pid, amount)
  local max = module.get_max_saturation(pid)
  local value = math.clamp(amount, 0, max)

  data.set_field(pid, cat, f_s, value)
  module_utils.update(pid, cat, f_s, value)
end

function module.full(pid)
  local max_h = module.get_max_hunger(pid)
  local max_s = module.get_max_saturation(pid)

  module.set_hunger(pid, max_h)
  module.set_saturation(pid, max_s)
end

function module.add(pid, hunger, saturation)
  if hunger and hunger ~= 0 then
    local h = module.get_hunger(pid) + (hunger or 0)
    module.set_hunger(pid, h)
  end
  if saturation and hunger ~= 0 then
    local s = module.get_saturation(pid) + (saturation or 0)
    module.set_saturation(pid, s)
  end
end

function module.consume(pid, amount)
  local s = module.get_saturation(pid)

  local new_s = s - amount
  if new_s < 0 then
    local abs_s = math.abs(new_s)
    local max_h = module.get_max_hunger(pid)

    module.set_saturation(pid, 0)

    local consumed = math.ceil(abs_s / max_h)
    if consumed < 1 then consumed = 1 end

    module.add(pid, -consumed)
  else
    module.set_saturation(pid, new_s)
  end
end

return module
