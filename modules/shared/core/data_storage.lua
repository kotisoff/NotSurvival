local constants = require "shared/core/constants"

local module    = {
  data = {}
};

local bus       = {};

local data_path = string.format("world:data/%s", constants.pack_id)

function module.load()
  if not file.exists(data_path) then
    file.mkdirs(data_path);
  end

  for _, value in ipairs(file.list(data_path)) do
    if file.ext(value) == "bjson" then
      local key = file.stem(value);
      local bytes = file.read_bytes(value);
      local data = bjson.frombytes(bytes);

      module.data[key] = data;
    end
  end
end

local function save_data(key, value)
  local bytes = bjson.tobytes(value, true);
  local path = string.format("%s/%s.bjson", data_path, key);

  file.write_bytes(path, bytes);
end

---@param save_key string | nil
function module.save(save_key)
  for _, value in ipairs(bus) do
    local fun, key = unpack(value);

    if not key or save_key == key then
      fun();
    end
  end

  if save_key and module.data[save_key] then
    save_data(save_key, module.data[save_key]);
    return;
  end

  for key, value in pairs(module.data) do
    save_data(key, value);
  end
end

---@param fun function
---@param key? string
function module.on_save(fun, key)
  table.insert(bus, { fun, key });
end

ns_events.on("world_quit", function()
  bus = {};
end);

return module;
