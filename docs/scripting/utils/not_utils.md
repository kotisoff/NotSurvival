# Утилиты - *api.utils.utils*

Удалить предмет в руке игрока.

```lua
inventory.consume_selected(player_id: number)
```

Получение индекса предмета. Даже если это блок.

```lua
not_utils.index_item(itemname: string|number) -> nil|number
```

Округление до определённого десятка.

```lua
not_utils.round_to(
  -- Само число
  num: number,
  -- Десяток. 10, 100, 1000 и тд
  accuracy: number
) -> number
```

Случайное выполнение функции. Шанс от 0 до 1.

```lua
not_utils.random_cb(chance: number, cb: function)
```

Создаёт корутину.

```lua
not_utils.create_coroutine(func: function)
```

Простое ожидание.

```lua
not_utils.sleep(timesec: number)
```

Ожидание с функцией для остановки и цикличной задачи. Возвращает true или false в зависимости была ли функция остановлена с помощью break_callback.

```lua
not_utils.sleep_with_break(timesec: number, break_callback: function, cycle_task: function) -> boolean
```

Парсит строку.

- Кушает функции типа `function() print("meow") end`
- Пути к модулям типа `not_survival:survival/death_manager` (если они возвращают чисто функцию)
- Пути к модулям с функциями через "@", типа `not_survival:survival/death_manager@kill`

```lua
not_utils.parse_callback_string(str) -> function
```

[Вернуться на главную](index.md)
