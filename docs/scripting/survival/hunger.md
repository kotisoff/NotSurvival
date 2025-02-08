# Модуль голода - *api.survival.hunger*

## Работа с голодом игрока

Возвращает кол-во голода игрока.

```lua
hunger.get(player_id: number) -> number
```

Возвращает максимум голода игрока.

```lua
hunger.get_max(player_id: number) -> number
```

Возвращает кол-во насыщения игрока.

```lua
hunger.get_saturation(player_id: number) -> number
```

Возвращает максимум насыщения игрока.

```lua
hunger.get_max_saturation(player_id: number) -> number
```

Устанавливает игроку кол-во голода.

```lua
hunger.set(player_id: number, amount: number)
```

Устанавливает игроку кол-во сытости.

```lua
hunger.set_saturation(player_id: number, amount: number)
```

Съедает выбранную в данный момент игроком еду. Устарело.

Вместо этого следует использовать новое свойство: "not_survival:food".
Подробнее в [юзер-пропах](../../user-props.md)

```lua
hunger.eat(
  -- Идентификатор игрока
  player_id: number,
  data: {
    -- Кол-во голода
    food: number,
    -- Кол-во сытости
    saturation: number,
    -- Есть еду даже при полном голоде? (опционально)
    eat_anyway?: boolean,
    -- Кол-во секунд на употребление еды (опционально)
    eat_delay?: number,
    -- Забирать ли предмет после употребления? (опционально)
    consume_item?: boolean,
    -- Замента предмета после поедания. (опционально)
    replace_item?: number,
    -- Тип еды.
    food_type?: "food" | "drink",
    -- Функция, выполняющаяся после употребления еды. (опционально)
    callback?: function(player_id: number)
  }
)
```

Восстанавливает игроку определённое кол-во голода и насыщения.

```lua
hunger.add(
  -- Идентификатор игрока
  player_id: number,
  -- Кол-во голода
  hunger: number,
  -- Кол-во сытости
  saturation: number
)
```

Полностью восстанавливает голод и сытость игрока.

```lua
hunger.full(pid)
```

Тратит сытость.
Может тратить и голод, если указать число выше 20.

```lua
hunger.consume(
  -- Идентификатор игрока
  player_id: number,
  -- Кол-во сытости
  saturation: number
)
```

[Вернуться на главную](../index.md)
