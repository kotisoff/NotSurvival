# Модуль эффектов - *api.survival.effects*

Выдать эффект игроку. Возвращает true или false в зависимости от факта существования эффекта.

```lua
effects.give(
  pid: number, identifier: string, level: number,
  duration: number, log: boolean
) -> boolean
```

Удаляет эффект игроку. Если идентификатор не предоставлен, удаляет все.

```lua
effects.remove(pid: number, identifier?: string, log?: boolean)
```

[Вернуться на главную](../index.md)
