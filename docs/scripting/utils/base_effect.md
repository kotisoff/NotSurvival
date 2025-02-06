# Класс базового эффекта - *api.utils.BaseEffect*

## Создание эффекта

Создать эффект довольно просто. Создадим эффект сытости как в моде по умолчанию.

```lua
-- Для работы нам необходимы
local api = require "api"; -- апи мода, для подключения остальных модулей.
local hunger = api.survival.hunger; -- Модуль голода.
local Registry = api.registry; -- Модуль регистра.
local BaseEffect = api.utils.BaseEffect; -- Собственно сам класс эффекта.

-- Итак, давайте создадим сам эффект.
local Saturation = BaseEffect.new("not_survival:saturation"); -- В агрументах идентификатор эффекта.

-- Функция, выполняемая каждый тик.
-- В аргументах тело класса, идентификатор игрока, уровень эффекта, его длительность и кол-во прошедших секунд с начала.
Saturation.tick = function(self, pid, level, duration, time_passed)
  hunger.add(pid, 1, 2); -- Восстанавливаем игроку 1 голод и 2 сытости в тик.
end

-- Давайте зарегистрируем эффект в регистре.
-- В аргументах нужный регистр, идентификатор эффекта и сам эффект.
Registry:register(Registry.TYPES.EFFECTS, Saturation.identifier, Saturation);
```

## Список переназначаемых функций

Выполняется каждый тик.

```lua
MyEffect.tick(self: Effect, pid: number, level: number, duration: number, time_passed: number)
```

Выполняется при получении эффекта.

```lua
MyEffect.on_applied(self: Effect, pid: number, level: number, duration: number)
```

Выполняется при удалении эффекта.

```lua
MyEffect.on_removed(self: Effect, pid: number)
```

[Вернуться на главную](../index.md)
