# Модуль режима игры

Возращает режим игры игрока.

```lua
gamemode.get_player_mode(player_id: number) -> number
```

Устанавливает режим игры для игрока.

```lua
gamemode.set_player_mode(
  -- Идентификатор игрока
  player_id: number,
  -- Режим игры
  gamemode: string | number
)
```

Структура таблицы с режимами игры

```lua
gamemode.modes = {
  name: string,
  handler: function(player_id: number)
}[]
```

Регистрация своего режима игры.

```lua
gamemode.register(
  -- Название режима игры
  name: string,
  -- Функция, котрая будет выполняться при смене режима игры.
  handler: function(player_id: number)
)
```

Устанавливает правила мира.
`true` - разрешены все читерские возможности игры.
`false` - запрещены все читерские возможности игры.

```lua
gamemode.set_creative_rules(state: boolean)
```

Устанавливает читерские возможности игрока.
Полёт, noclip, бесконечные предметы и мгновенное ломание.

```lua
gamemode.set_creative_player_states(
  player_id: number,
  state: boolean
)
```

[Вернуться на главную](main.md)
