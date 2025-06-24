local data = require "shared/player/data"

local module = {}

---@return number
function module.get(pid)
  return data.get_data(pid, "health")
end

---@return number
function module.get_max(pid)
  return data.get_attributes(pid, "health")
end

function module.set(pid, value)
  local max = module.get_max(pid)
  local new_val = math.clamp(value, 0, max)

  data.set_field(pid, "data", "health", new_val)
end

function module.full(pid)
  module.set(pid, module.get_max(pid))
end

function module.add(pid, amount)
  local value = module.get(pid)
  module.set(pid, value + (amount or 1))
end

function module.damage(pid, amount, options)
  module.add(pid, -amount)
end
