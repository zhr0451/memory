# Инструменты

- **Godot 4.7.2** (flatpak `org.godotengine.Godot`); обёртка `~/.local/bin/godot` (`flatpak run --filesystem=host`).
- **MCP godot** — `.mcp.json`, пакет [`@coding-solo/godot-mcp`](https://github.com/Coding-Solo/godot-mcp) (MIT): запуск редактора/проекта, вывод отладки, создание сцен/узлов. Требует одобрения при первом запуске Claude Code. Переменная `GODOT_PATH` указывает на обёртку.
- **Skills** (`.claude/skills/`): `new-feature` — скаффолд фичи MVVM.
- Тесты: рекомендуется [GUT](https://github.com/bitwiseman/gut) или gdUnit4 — добавить при первой фиче с логикой (не установлено).
- Проверка парсинга: `godot --headless --path . --import` (парсинг скриптов/ресурсов; ошибки видны в выводе).
