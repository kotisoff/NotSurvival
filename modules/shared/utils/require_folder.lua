local packid = require "shared/core/constants".pack_id;

---@param folder string
return function(folder)
  local dir = file.join(pack.get_folder(packid), "modules/" .. folder)
  local collection = {};

  for _, path in ipairs(file.list(dir)) do
    if file.isfile(path) then
      local basename = file.stem(path)
      collection[basename] = require(file.join(folder, basename))
    end;
  end

  return collection
end
