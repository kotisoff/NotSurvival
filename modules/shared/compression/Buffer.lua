local module = {};

---@class ns.network.Buffer
---@field append fun(buffer: ns.network.Buffer, data: any)
---@field read_next fun(buffer: ns.network.Buffer): any
---@field next int
---@field value any[]

---@param buffer ns.network.Buffer
local function append(buffer, data)
  table.insert(buffer.value, data);
end

---@param buffer ns.network.Buffer
local function read_next(buffer)
  local index = buffer.next;
  buffer.next = buffer.next + 1;

  return buffer.value[index];
end

---@param data? any[]
function module.new(data)
  ---@type ns.network.Buffer
  local buffer = {
    value = data or {},
    next = 1,
    read_next = read_next,
    append = append
  }

  return buffer;
end

return module;
