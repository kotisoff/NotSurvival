# Модуль переменных игрока - *api.player.variables*

## Текущие данные

Возможна перезапись переменных, пользуйтесь аккуратно.

Возвращает текущие данные игрока.

```lua
variables.get_player_data(player_id: number) -> table
```

Возвращает атрибуты, также известные как максимальные значения данных игрока.

```lua
variables.get_player_attributes(player_id: number) -> table
```

Возвращает последний источник урона игрока.

```lua
variables.get_player_damage(player_id: number) -> table
```

## Новые экземпляры

Рекомендуется использовать их для итерирования в скриптах, которые не требуют самих данных игрока, а только её карту.

Возвращает новый экземпляр данных игрока.

```lua
variables.new_player_data() -> table
```

Возвращает новый экземпляр атрибутов игрока.

```lua
variables.new_player_attributes() -> table
```

Возвращает новый экземпляр источника урона игрока.

```lua
variables.new_player_damage() -> table
```

## Структуры данных

Данные игрока

```lua
Player: {
    gamemode: number,
    health: number,
    hunger: number,
    saturation: number,
    xp: number,
    oxygen: number,
    armor: number
}
```

Атрибуты игрока

```lua
PlayerAttributes: {
    health: number,
    hunger: number,
    saturation: number,
    oxygen: number,
    armor: number
}
```

Источник урона

```lua
DamageSource: {
    source: vec3,
    type: string,
    amount: number
}
```

[Вернуться на главную](../index.md)
