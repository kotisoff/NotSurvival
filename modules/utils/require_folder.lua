local packid = "not_survival"

---@param folder string
return function(folder)
  local files = file.join(pack.get_folder(packid), "modules/" .. folder)
  for _, path in ipairs(file.list(files)) do
    local basename = file.stem(path)
    require(file.join(folder, basename))
  end
end
