# Модуль опыта - *api.survival.experience*

## Работа с опытом игрока

Возвращает количество опыта игрока.

```lua
experience.get_xp(player_id: number) -> number
```

Возвращает количество уровней опыта игрока.

```lua
experience.get_lvl(player_id: number) -> number
```

Создаёт энтити опыта в виде сферы. При подборе выдаёт игроку это кол-во опыта.
Если кол-во не указано, число будет от 1 до 10. Отрицательное кол-во будет забирать опыт .\_.

```lua
experience.summon(
  -- Позиция для создания энтити.
  pos: vec3
  -- Кол-во опыта.
  amount: number|nil
)
```

Выдаёт определённое кол-во опыта игроку.

```lua
experience.give(
  -- Идентификатор игрока
  player_id: number,
  -- Количество опыта
  amount: number
)
```

Забирает у игрока определённое кол-во опыта.

```lua
experience.drain(
  -- Идентификатор игрока
  player_id: number,
  -- Количество опыта
  amount: number
) -> boolean
```

Забирает у игрока определённое кол-во уровней опыта.

```lua
experience.drain_lvl(
  -- Идентификатор игрока
  player_id: number,
  -- Количество уровней
  amount: number
) -> boolean
```

Устанавливает игроку определённое кол-во опыта.

```lua
experience.set_xp(
  -- Идентификатор игрока
  player_id: number,
  -- Количество опыта
  amount: number
)
```

Устанавливает игроку определённое кол-во уровней опыта.

```lua
experience.set_lvl(
  -- Идентификатор игрока
  player_id: number,
  -- Количество уровней
  amount: number
)
```

## Вспомогательные функции

Возвращает количество опыта для поднятия следующего уровня.

```lua
experience.calc_max(level: number) -> number
```

Возвращает количество опыта из уровня.

```lua
experience.calc_total(level: number) -> number
```

Возвращает количество уровней из опыта.

```lua
experience.calc_lvl(total_exp: number) -> number
```

[Вернуться на главную](../index.md)
