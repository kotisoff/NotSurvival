# Модуль опыта

### Работа с опытом игрока.

Возвращает количество опыта игрока.

```lua
exp.get_xp(player_id: number) -> number
```

Возвращает количество уровней опыта игрока.

```lua
exp.get_lvl(player_id: number) -> number
```

Выдаёт определённое кол-во опыта игроку.

```lua
exp.give(
  -- Идентификатор игрока
  player_id: number,
  -- Количество опыта
  amount: number
)
```

Забирает у игрока определённое кол-во опыта.

```lua
exp.drain(
  -- Идентификатор игрока
  player_id: number,
  -- Количество опыта
  amount: number
) -> boolean
```

Забирает у игрока определённое кол-во уровней опыта.

```lua
exp.drain_lvl(
  -- Идентификатор игрока
  player_id: number,
  -- Количество уровней
  amount: number
) -> boolean
```

Устанавливает игроку определённое кол-во опыта.

```lua
exp.set_xp(
  -- Идентификатор игрока
  player_id: number,
  -- Количество опыта
  amount: number
)
```

Устанавливает игроку определённое кол-во уровней опыта.

```lua
exp.set_lvl(
  -- Идентификатор игрока
  player_id: number,
  -- Количество уровней
  amount: number
)
```

### Вспомогательные методы.

Возвращает количество опыта для поднятия следующего уровня.

```lua
exp.calc_max(level: number) -> number
```

Возвращает количество опыта из уровня.

```lua
exp.calc_total(level: number) -> number
```

Возвращает количество уровней из опыта.

```lua
exp.calc_lvl(total_exp: number) -> number
```

[Вернуться на главную](main.md)
