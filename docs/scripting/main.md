# Скриптинг с NotSurvival

### Работа с **api**

Для начала необходимо импортировать api мода.
Для этого можно в файле скрипта прописать следующее.

```lua
local not_survival_api = require "not_survival:api"
```

В следующих модулях методы прописаны без `not_survival_api`.
В теории их можно использовать и без этого, но я крайне рекомендую перед ними написать `not_survival_api.`
Пример:
```lua
not_survival_api.exp.give(0, 5);
```

### Модули

#### Выживание

- [Опыт](experience.md)
- [Здоровье](health.md)
- [Голод](hunger.md)
- [Кислород](oxygen.md)

#### Остальные

- [Режим игры](gamemode.md)
- [Переменные игрока](variables.md)
- [Физика передвижения](movement.md)
