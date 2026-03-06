local counters = {}
local counter_store = {}

---@class ns.utils.Counter
---@field id int
---@field field str
local module = {}
module.__index = module

---@param default? number
function module:get(default)
  local store = counter_store[self.field];
  if not store then return default end
  return store[self.id] or default
end

function module:add(value)
  counter_store[self.field][self.id] = self:get(0) + value
end

function module:set(value)
  counter_store[self.field][self.id] = value
end

function module:destroy()
  counter_store[self.field][self.id] = nil;
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

function module.cleanup_id(id)
  for _, map in pairs(counters) do
    if map[id] then
      map[id]:destroy();
      map[id] = nil;
    end
  end
end

function module.get_or_create(pid, field)
  return (counters[field] or {})[pid] or module.new(pid, field)
end

return module
