local counters = {}
local counter_store = {}

---@class ns.utils.Counter
---@field id int
---@field field str
local module = {}
module.__index = module

---@param default? number
function module:get(default)
  return counter_store[self.field][self.id] or default
end

function module:add(value)
  counter_store[self.field][self.id] = self:get(0) + value
end

function module:set(value)
  counter_store[self.field][self.id] = value
end

function module.new(id, field)
  counter_store[field] = counter_store[field] or {}
  local counter = setmetatable({ id = id, field = field }, module)

  if not counters[field] then
    counters[field] = {}
  end

  counters[field][id] = counter

  return counter
end

function module.get_or_create(pid, field)
  return (counters[field] or {})[pid] or module.new(pid, field)
end

return module
