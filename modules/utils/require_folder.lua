---@param folder string
return function(folder)
  local files_path = "not_survival:modules/" .. folder

  -- Ультра костыль, ибо я не хочу каждый раз добавлять строку с require.
  for _, filepath in pairs(file.list(files_path)) do
    ---@diagnostic disable-next-line: undefined-field
    local arr = string.split(filepath, "/");
    ---@diagnostic disable-next-line: undefined-field
    local arr2 = string.split(arr[#arr], ".")
    table.remove(arr2, #arr2);
    local filename = table.concat(arr2, ".");

    require(folder .. "/" .. filename);
  end
end
