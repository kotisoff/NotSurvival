---@diagnostic disable: undefined-field

local files_path = "not_survival:modules/survival/effects"
local import_path = "survival/effects/";

-- Ультра костыль, ибо я не хочу каждый раз добавлять строку с require.
for _, filepath in pairs(file.list(files_path)) do
  local arr = string.split(filepath, "/");
  local arr2 = string.split(arr[#arr], ".")
  table.remove(arr2, #arr2);
  local filename = table.concat(arr2, ".");

  if filename == "init" then goto continue end;
  require(import_path .. filename);
  ::continue::
end
