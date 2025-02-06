# Модуль смерти - *api.survival.death*

Убить игрока.

```lua
death.kill(player_id: number, reason: string)
```

Выбрасывает все вещи из инвентаря игрока.

```lua
death.drop_items(player_id: number)
```

Возрождает игрока. Если правило `ns-keep-inventory` было отключено, выбрасывает все вещи из инвентаря игрока и извлекает опыт в виде зелёных сфер.

```lua
death.revive(player_id: number)
```

[Вернуться на главную](index.md)
