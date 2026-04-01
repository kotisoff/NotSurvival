local module = {
  loaders = {},
};

local resources = {
  "tags/mineable"
}

function module.reload()
  for _, loader in ipairs(module.loaders) do
    loader.reload();
  end
end

function module.init()
  for _, path in ipairs(resources) do
    table.insert(module.loaders, require("shared/lib/loaders/" .. path));
  end

  module.reload();
end

return module;
