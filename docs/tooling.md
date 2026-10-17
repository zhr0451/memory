# Инструменты

- **Godot 4.7.2** (flatpak `org.godotengine.Godot`); обёртка `~/.local/bin/godot` (`flatpak run --filesystem=host`).
- **MCP godot** — `.mcp.json`, пакет [`@coding-solo/godot-mcp`](https://github.com/Coding-Solo/godot-mcp) (MIT): запуск редактора/проекта, вывод отладки, создание сцен/узлов. Требует одобрения при первом запуске Claude Code. Переменная `GODOT_PATH` указывает на обёртку.
- **Skills** (`.claude/skills/`): `new-feature` — скаффолд фичи MVVM.
- Тесты: свой мини-раннер без плагинов. `godot --headless --path . -s tests/test_runner.gd` ищет `*_test.gd` в `core/` и `features/` (класс `extends TestCase`, методы `test_*`, проверки `check`/`check_eq`). Тесты лежат в `features/<f>/tests/` и `core/tests/`; гоняются в CI.
- Дымовой прогон всей игры без ввода: `godot --headless --path . -s tests/smoke_playthrough.gd` (~1 мин, печатает `SMOKE OK`).
- Проверка парсинга: `godot --headless --path . --import` (парсинг скриптов/ресурсов; ошибки видны в выводе).

## CI и публикация
- Репозиторий: <https://github.com/zhr0451/memory> (публичный). Игра: <https://zhr0451.github.io/memory/>.
- Workflow [`.github/workflows/web.yml`](../.github/workflows/web.yml) («Web export»): Godot и шаблоны экспорта `GODOT_VERSION` (4.7.2) качаются из `godotengine/godot-builds`, затем `--import` и `--export-release Web build/web/index.html`.
- Пресет `Web` — [`export_presets.cfg`](../export_presets.cfg); без потоков (`thread_support=false`), потому что Pages не отдаёт COOP/COEP. `build/` в `.gitignore`.
- Триггеры: пуш в `main` → экспорт и деплой на GitHub Pages (Pages в режиме `workflow`); PR → только экспорт; тег `v*` → экспорт и GitHub Release с архивом `memory-web.zip` (содержимое веб-сборки в корне архива).
- Выпуск релиза: `git tag vX.Y.Z && git push origin vX.Y.Z`. Проверено на `v0.0.1`.
- При смене версии Godot обновить `GODOT_VERSION` в workflow.
