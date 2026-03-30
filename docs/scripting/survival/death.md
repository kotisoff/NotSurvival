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

## Ивенты

Ивент вызывается прямо перед тем как установить статус смерти игрока. Если в функцию вернуть true -> Смерть отменяется.

```lua
events.on("not_survival:before_death", function(pid, reason, damage) -> bool)
```

Ивент вызывается после установления статуса смерти игрока. Не отменяется.

```lua
events.on("not_survival:on_death", function(pid, reason) -> void)
```

Ивент вызывается при возрождении игрока.

```lua
events.on("not_survival:on_revive", function(pid, death_location) -> void)
```

[Вернуться на главную](../index.md)
