# Логгер - *api.utils.Logger*

## Использование

```lua
-- Импортируем апи и из него логгер
local api = require "not_survival:api";
local Logger = api.utils.Logger;

-- Создадим новый инстанс логгера
local log = Logger.new("my_pack_id", "TestLogger");

-- Теперь можно пользоваться логгером.
```

Функций у логгера немного и он по сути нужен для сохранения логов и возможности их писать без вывода в консоль игры.

Выводит данные в таблицу silentlogs.

```lua
log:silent(...: string[])
```

Выводит данные в таблицу logs.

```lua
log:info(...: string[])
```

Сохраняет логи silentlogs в файл в config:packid/loggername-latest.log

```lua
log:save()
```

Выводит все логи из таблицы logs в консоль разом. Не последовательно, а одним многострочным сообщением.

```lua
log:print()
```

Выводит данные напрямую в консоль.

```lua
log:println(...: string[])
```

[Вернуться на главную](../index.md)
