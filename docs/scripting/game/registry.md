# Модуль регистра - *api.registry*

## Использование

Типы регистров. На данный момент существует только регистр эффектов. Используется как аргумент type в методах регистрации и получения.

```lua
---@enum registry_types
Registry.TYPES = {
  EFFECTS = 1
}
```

Регистрирует объект

```lua
Registry:register(
  -- Тип регистра из Registry.TYPES
  type: registry_types,
  -- Идентификатор. Как правило указывается идентификатор_пака:название_объекта
  identifier: string,
  -- Объект, который будет зарегистрирован
  object: table
  -- Переписать значение, если такой объект уже существует
  overwrite?: boolean
)```

Получение объекта из регистра

```lua
Registry:get(
  -- Тип регистра из Registry.TYPES
  type: registry_types,
  -- Идентификатор объекта
  identifier: string
) -> table|nil
```

Получение всех объектов определённого типа

```lua
Registry:get_all_of(
  -- Тип регистра из Registry.TYPES
  type: registry_types
) -> table<string, table>|nil
```

[Вернуться на главную](../index.md)
