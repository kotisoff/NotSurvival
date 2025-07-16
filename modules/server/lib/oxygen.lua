local data = require "shared/player/data"
local module_utils = require "server/lib/util/module_utils"

---@type ns.categories, ns.statusfield | ns.attributefield
local cat, field = "data", "oxygen"

local module = {}

---@return number
function module.get(pid)
  return data.get_data(pid, field)
end

---@return number
function module.get_max(pid)
  return data.get_attributes(pid, field)
end

function module.set(pid, value)
  local max = module.get_max(pid)
  local new_val = math.clamp(value, 0, max)

  data.set_field(pid, cat, field, new_val)
  module_utils.update(pid, cat, field, new_val)
end

function module.full(pid)
  module.set(pid, module.get_max(pid))
end

function module.add(pid, amount)
  local value = module.get(pid)
  module.set(pid, value + (amount or 1))
end

return module
