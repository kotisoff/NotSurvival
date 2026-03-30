# Модуль сна - *api.player.sleeping*

Собственно сон.

```lua
sleeping.sleep(
  -- Позиция блока.
  block_pos: vec3,
  -- До какого времени игрок будет спать.
  day_time: number,
  -- Опционально. Анимировать сон?
  animate: boolean|nil,
  -- Опционально. Длина анимации сна.
  animation_time: number|nil
)
```

## Ивенты

Ивент вызывается перед тем как лечь спать. Отменяется если вернуть true.

```lua
events.on("not_survival:on_sleep_start", function(pid, sleep_start_time, sleep_end_time) -> bool)
```

Вызывается когда сон завершён. Аргумент interrupted означает был ли сон прерван или неь.

```lua
events.on("not_survival:on_sleep_end", function(pid, sleep_start_time, sleep_end_time, interrupted) -> void)
```

[Вернуться на главную](../index.md)
