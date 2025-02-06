# Модуль здоровья - *api.survival.health*

## Работа с здоровьем игрока

Возвращает кол-во здоровья игрока.

```lua
health.get(player_id: number) -> number
```

Возвращает максимум здоровья игрока.

```lua
health.get_max(player_id: number) -> number
```

Восстанавливает игроку определённое кол-во здоровья.

```lua
health.heal(player_id: number, amount: number)
```

Полностью восстанавливает здоровье игрока.

```lua
health.full(pid)
```

Устанавливает игроку определённое кол-во здоровья.

```lua
health.set(player_id: number, amount: number)
```

Наносит игроку урон и отталкивает.

```lua
health.damage(
  -- Идентификатор игрока
  player_id: number,
  -- Кол-во урона
  damage: number,
  -- Тип урона (опционально)
  damage_type: string | nil,
  -- Источник урона (опционально)
  source: vec3 | nil,
  -- Отталкивать игрока? (опционально)
  do_knockback: boolean | nil,
  -- Название звука (опционально),
  playsound: string | boolean | nil
)
```

Отталкивает игрока.

```lua
health.knockback(
  -- Идентификатор игрока
  player_id: number,
  -- Источник урона (опционально)
  source: vec3,
  -- Сила отталкивания (опционально, по умолчанию 6)
  knockback_multiplier: number
)
```

[Вернуться на главную](index.md)
