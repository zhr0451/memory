# Конвенции

- Файлы/папки: `snake_case`; классы: `PascalCase` через `class_name`; константы: `UPPER_SNAKE`; приватное: `_prefix`.
- Суффиксы: `*_view.gd`, `*_view_model.gd`, модели без суффикса.
- Типы обязательны: `var x: int`, `func f(a: String) -> void`.
- Сигналы — в прошедшем времени (`score_changed`). Команды VM — глаголы (`flip_card`).
- Порядок в классе: `class_name`, `extends`, сигналы, константы, `@export`, переменные, `_ready`/виртуальные, публичные методы, приватные.
- Не использовать `get_node` с длинными путями; `%UniqueName` или `@onready` с `@export` NodePath.
- Коммиты: короткие, императив; один логический шаг на коммит.
- Бинарные ассеты (png, ogg, wav, ttf, glb…) идут через Git LFS; `.tscn/.tres/.gd` — обычный текст.
- Файлы `*.uid` коммитим; `.godot/` — нет.
