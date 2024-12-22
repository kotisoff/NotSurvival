# Модуль текста на экране

Из-за отсутствия адекватного изменения размера текста на экране, текст похож друг на друга. Просто

### Показ текста

Показывает текст на экране прямо над полосками здоровья.

```lua
title.actionbar:show(text: string)
```

Показывает текст на экране посередине.

```lua
title.title:show(text: string)
```

Показывает текст на экране чуть ниже середины.

```lua
title.subtitle:show(text: string)
```

### Дополнительные, обычно бесполезные.

Все типы текста на экране.

```lua
title.types
```

Устанавливает прозрачность элементу name в xml-ке title от 0 до 255.

```lua
title.utils.set_opacity(name: string, opacity: number)
```

Цикл для исчезания элемента.
Функция для not_utils.sleep_with_break, сама по себе не особо полезна.

```lua
title.utils.fade_out_cycle(
  --Название элемента.
  name: string,
  -- Таблица с временными данными.
  data: table,
  -- Текущее время от 0 до total_time.
  curr_time: number,
  -- Начало исчезновения элемента
  fade_start_time: number,
  -- Время в секундах, общая задержка в функции sleep.
  total_time: number
)
```

Цикл для появления элемента.
Действует так же, как и fade_out_cycle.

````lua
title.utils.fade_in_cycle(
  --Название элемента.
  name: string,
  -- Таблица с временными данными.
  data: table,
  -- Текущее время от 0 до total_time.
  curr_time: number,
  -- Начало исчезновения элемента
  fade_start_time: number,
  -- Время в секундах, общая задержка в функции sleep.
  total_time: number
)```

[Вернуться на главную](main.md)
````
