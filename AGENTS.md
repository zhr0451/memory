# Он меня найдёт (проект `Memory`) — контекст для агентов

Короткое нарративное point-and-click приключение от первого лица, Ludum Dare (тема «старые технологии»), срок 2,5 дня, 10–15 минут игры. Герой — старая электронная игрушка, очнувшаяся на свалке; игрок видит мир её глазами, в финале узнаёт, что её выбросили. Тон: тихая грусть. Godot 4.7 (GL Compatibility, Jolt), GDScript, экспорт в HTML5.

Документы:
- [docs/game-design.md](docs/game-design.md) — GDD v2 (источник истины по геймдизайну, сюжету, эмоциям, мини-играм)
- [docs/features.md](docs/features.md) — фича-лист, приоритеты, карта «фича → папка»
- [docs/assets.md](docs/assets.md) — ассеты, размеры, правила экспорта
- [docs/roadmap.md](docs/roadmap.md) — спринты и правила резки
- [docs/architecture.md](docs/architecture.md), [docs/conventions.md](docs/conventions.md), [docs/tooling.md](docs/tooling.md)

## Ключевые ограничения дизайна
- База проекта 1920×1080, арт 1:1; зум камеры на свалке до ~1,3×.
- **Покадровой анимации нет**: всё движение — твины и шейдеры.
- Только мышь. Проиграть нельзя. 4 главы/предмета: диафильм → будильник → кассетный плеер → видеокамера (камера — should, режется первой; финал не режем).
- 7 эмоций лица: joy, memory, worry, fear, doubt, sad, off. Батарейка: 5 состояний (4 → 0), −1 за главу.
- Все тексты в одном JSON (`core/texts`), без хардкода в коде.
- Код пишем на заглушках, арт подставляется по мере готовности (код не ждёт художника).

## Главные правила
1. **Код вместо редактора.** Сцены (`.tscn`), ресурсы (`.tres`), `project.godot` пишем и правим текстом/GDScript. В редактор — только для того, что нельзя выразить кодом (импорт ассетов, визуальная отладка).
2. **MVVM.** View (Node) ↔ ViewModel (`RefCounted`) ↔ Model (`Resource`/`RefCounted`). Направление зависимостей: View → ViewModel → Model. Model и ViewModel не знают про `Node`/сцену.
3. **Feature-first.** Каждая фича целиком живёт в `features/<feature>/` (model, viewmodel, view, сцены, ассеты, тесты). Фичи не импортируют внутренности друг друга; общение — через сигналы/события из `core/` или публичный интерфейс фичи.
4. **Статическая типизация** везде в GDScript, `class_name` для публичных типов.
5. Перед завершением задачи: проверить парсинг проекта (`godot --headless --path . --import`) и прогнать тесты, если есть.

## Структура
```
core/mvvm/     базовые классы (Observable, ViewModel)
core/          общая инфраструктура без привязки к фичам (события, сервисы)
shared/        переиспользуемые UI-компоненты, темы, шрифты
features/<f>/  model/ viewmodel/ view/ assets/ tests/ + <f>.tscn
```
Создание фичи: skill `/new-feature` ([.claude/skills/new-feature/SKILL.md](.claude/skills/new-feature/SKILL.md)).

## Инструменты
- Godot: `~/.local/bin/godot` (обёртка над flatpak, 4.7.2). Headless: `godot --headless --path . --import` (парсинг скриптов/ресурсов; ошибки видны в выводе).
- MCP `godot` (`.mcp.json`, `@coding-solo/godot-mcp`) — запуск/отладка/инспекция проекта.
- Git LFS включён для бинарных ассетов (см. `.gitattributes`).
