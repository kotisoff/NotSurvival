local module = {
  registry = {}
}

function module.get(key)
  return module.registry[key] or key
end

function module.set(key, text)
  module.registry[key] = text
end

return module
