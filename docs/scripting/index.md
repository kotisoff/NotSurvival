# Скриптинг с NotSurvival

## Работа с **api**

Для начала необходимо импортировать api мода.
Для этого можно в файле скрипта прописать следующее.

```lua
local not_survival_api = require "not_survival:api"
```

Пример:

```lua
not_survival_api.exp.give(0, 5);
```

### Модули

- [Регистр](game/registry.md)

#### Выживание

- [Опыт](survival/experience.md)
- [Здоровье](survival/health.md)
- [Голод](survival/hunger.md)
- [Кислород](survival/oxygen.md)
- [Смерть](survival/death.md)
- [Эффекты](survival/effects.md)

#### Игра

- [Режим игры](game/gamemode.md)
- [Текст на экране](game/title.md)

#### Игрок

- [Сон](player/sleeping.md)
- [Переменные игрока](player/variables.md)
- [Физика передвижения](player/movement.md)

#### Утилиты

- [not_utils](utils/not_utils.md)
- [Логгер](utils/logger.md)
- [Загрузчик ресурсов](utils/resource_loader.md)
- [Базовый эффект](utils/base_effect.md)

[Вернуться на главную](../index.md)
