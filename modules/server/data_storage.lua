local constants = require "shared/core/constants"
local module    = {
  data = {}
};

local data_path = string.format("world:data/%s", constants.pack_id)

function module.load()
  if not file.exists(data_path) then
    file.mkdirs(data_path);
  end

  for index, value in ipairs(file.list(data_path)) do
    if file.ext(value) ~= "bjson" then
      return
    end

    local key = file.stem(value);
    local bytes = file.read_bytes(value);
    local data = bjson.frombytes(bytes);

    module.data[key] = data;
  end
end

function module.save()
  for key, value in pairs(module.data) do
    local bytes = bjson.tobytes(value, true);
    local path = string.format("%s/%s.bjson", data_path, key);

    file.write_bytes(path, bytes);
  end
end

return module;
