local module = {
  loaders = {},
  compressed_data = {}
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

function module.compress()
  local compressed = {};

  for key, loader in pairs(module.loaders) do
    compressed[key] = loader:compress();
  end

  local bytes = bjson.tobytes(compressed, true);

  module.compressed_data = bytes;
  return bytes;
end

function module.decompress(bytes)
  local compressed = bjson.frombytes(bytes);

  for key, data in pairs(compressed) do
    local loader = module.loaders[key];
    loader.data = loader:decompress(data);
  end
end

return module;
