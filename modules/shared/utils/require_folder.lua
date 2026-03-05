local packid = "not_survival"

---@param folder string
return function(folder)
  local dir = file.join(pack.get_folder(packid), "modules/" .. folder)
  local collection = {};

  for _, path in ipairs(file.list(dir)) do
    local basename = file.stem(path)
    collection[basename] = require(file.join(folder, basename))
  end

  return collection
end
