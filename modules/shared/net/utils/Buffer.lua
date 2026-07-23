local module = {};

---@class ns.network.Buffer
---@field append fun(buffer: ns.network.Buffer, data: any)
---@field read_next fun(buffer: ns.network.Buffer): any
---@field next int
---@field value any[]
local Buffer = {};

function Buffer:append(data)
  table.insert(self.value, data);
end

function Buffer:read_next()
  if self.next > #self.value then
    return nil -- Конец буфера
  end

  local index = self.next;
  self.next = self.next + 1;

  return self.value[index];
end

function Buffer:reset()
  self.next = 1;
end

---@param data? any[]
function module.new(data)
  return setmetatable({ value = data or {}, next = 1 }, {
    __index = Buffer
  });
end

function module.create_compressor()
  local compressor = {};

  function compressor.to_bytes(...)
    return { ... };
  end

  function compressor.from_bytes(bytes)
    return unpack(bytes);
  end

  return compressor;
end

return module;
