# Модуль кислорода - *api.survival.oxygen*

## Работа с кислородом игрока

Возвращает количество кислорода игрока.

```lua
oxygen.get(player_id: number) -> number
```

Возвращает максимум килорода игрока.

```lua
oxygen.get_max(player_id: number) -> number
```

Устанавливает игроку определённое кол-во кислорода.

```lua
oxygen.set(
  -- Идентификатор игрока
  player_id: number,
  -- Количество кислорода
  amount: number
)
```

Восстанавливает полное кол-во кислорода игроку.

```lua
oxygen.full(player_id: number)
```

Добавляет игроку определённое кол-во кислорода.

```lua
oxygen.add(player_id: number, amount: number)
```

Убавляет игроку определённое кол-во кислорода.

```lua
oxygen.sub(player_id: number, amount: number)
```

[Вернуться на главную](index.md)
