# Загрузчик ресурсов - *api.utils.ResourceLoader*

## Использование

Создадим простой загрузчик рецептов как в NotCrafting.

```lua
-- Для создания загрузчика по сути нам необходим только он.
local api = require "api";
local ResourceLoader = api.utils.ResourceLoader;

-- В аргументах идентификатор пака и навание логгера.
local recipe_loader = ResourceLoader.new("not_survival", "recipe_loader");

-- Отсканируем папку "resource/data" на наличие пакетов. Вторым аргументом идёт таблица с приоритетом загрузки.
recipe_loader:scan_packs("data", {"not_survival"});
-- Загрузим папки и сами json-ы в папке "resource/data/<packid>/recipe"
-- Вторым аргументом идёт функция фильтра. Отфильтруем файлы без данных.
recipe_loader:load_folders("recipe", function(resource_pack_id, filename, data) return data ~= nil end)

-- Дальше идут функции по парсингу json-ов. В конце концов у нас получается структура типа
-- table<resource_pack_id, table<filename, data>>
-- С которой работать особо труда составить не должно.
```

В общем ResourceLoader имеет только эти две функции, логгер и таблицу с загруженными элементами.

[Вернуться на главную](../index.md)
