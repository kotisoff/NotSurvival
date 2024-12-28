# Модуль текста на экране

Из-за отсутствия адекватного изменения размера текста на экране, текст похож друг на друга. Просто

### Показ текста

Показывает текст на экране прямо над полосками здоровья.

```lua
title.actionbar:show(
  -- Текст.
  text: string,
  -- Опционально. Кол-во секунд текста на экране.
  show_time: number|nil,
  -- Опционально. Функция, которая будет сразу убирать текст, если возвращает true.
  breakfunc: function|nil
)
```

Показывает текст на экране посередине. Аргументы по аналогии с actionbar.

```lua
title.title:show(text: string, show_time: number|nil, breakfunc: function|nil)
```

Показывает текст на экране чуть ниже середины. Аргументы по аналогии с actionbar.

```lua
title.subtitle:show(text: string, show_time: number|nil, breakfunc: function|nil)
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

[Вернуться на главную](main.md)
