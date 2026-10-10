local module = {
  loaders = {},
  compressed_data = {},
  local_hash = ""
};

module.loaders = {
  ["tags/mineable"] = require "shared/lib/loaders/tags/mineable",
}

function module.reload()
  for _, loader in pairs(module.loaders) do
    loader.reload();
  end

  module.compress();
end

---@return bytearray bytes, string hash
function module.compress()
  local compressed = {};

  for key, loader in pairs(module.loaders) do
    compressed[key] = loader:compress();
  end

  local bytes = bjson.tobytes(compressed, true);
  module.compressed_data = bytes;

  local hash = crypto.md5(Bytearray_as_string(bytes));
  module.local_hash = hash;

  return bytes, hash;
end

---@param bytes bytearray
---@param hash string
function module.decompress(bytes, hash)
  if hash == module.local_hash then return end;

  local compressed = bjson.frombytes(bytes);

  for key, data in pairs(compressed) do
    local loader = module.loaders[key];
    loader.data = loader:decompress(data);
  end
end

return module;
