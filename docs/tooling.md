# Инструменты

- **Godot 4.7.2** (flatpak `org.godotengine.Godot`); обёртка `~/.local/bin/godot` (`flatpak run --filesystem=host`). На macOS — `brew install --cask godot`, команда `godot` (`/opt/homebrew/bin/godot` → `/Applications/Godot.app`).
- **MCP godot** — `.mcp.json`, пакет [`@coding-solo/godot-mcp`](https://github.com/Coding-Solo/godot-mcp) (MIT): запуск редактора/проекта, вывод отладки, создание сцен/узлов. Требует одобрения при первом запуске Claude Code. Нужен Node.js (`npx`; на macOS — `brew install node`). Путь к Godot сервер ищет сам (`~/.local/bin/godot` на Linux, `/Applications/Godot.app` на macOS); если Godot лежит в другом месте — задать `GODOT_PATH` в окружении.
- **Skills** (`.claude/skills/`): `new-feature` — скаффолд фичи MVVM.
- Тесты: свой мини-раннер без плагинов. `godot --headless --path . -s tests/test_runner.gd` ищет `*_test.gd` в `core/` и `features/` (класс `extends TestCase`, методы `test_*`, проверки `check`/`check_eq`). Тест, во время которого движок выдал ошибку (SCRIPT ERROR, `push_error`), считается проваленным — раннер ловит их своим `Logger` (`OS.add_logger`). Тесты лежат в `features/<f>/tests/` и `core/tests/`; гоняются в CI.
- Дымовой прогон всей игры без ввода: `godot --headless --path . -s tests/smoke_playthrough.gd` (~1 мин, печатает `SMOKE OK`).
- Проверка парсинга: `godot --headless --path . --import` (парсинг скриптов/ресурсов; ошибки видны в выводе).

## CI и публикация
- Репозиторий: <https://github.com/zhr0451/memory> (публичный). Игра: <https://zhr0451.github.io/memory/>.
- Workflow [`.github/workflows/web.yml`](../.github/workflows/web.yml) («Web export»): Godot и шаблоны экспорта `GODOT_VERSION` (4.7.2) качаются из `godotengine/godot-builds`, затем `--import` и `--export-release Web build/web/index.html`.
- Сборка для itch.io и Ludum Dare локально: `tools/export_web.sh [zip]` (по умолчанию `build/memory-web.zip`). Скрипт экспортирует пресет `Web` и заменяет в `index.js` проверки `"serviceWorker" in navigator` на `false` — так требует [гайд LD по embed](https://ludumdare.com/resources/guides/embedding/) (песочница iframe 948×533, без IndexedDB/localStorage; Godot сам переходит на память, настройки живут до перезагрузки). Zip с `index.html` в корне подходит обоим сайтам; на itch — Kind of project: HTML, «This file will be played in the browser».
- Пресет `Web` — [`export_presets.cfg`](../export_presets.cfg); без потоков (`thread_support=false`), потому что Pages не отдаёт COOP/COEP. `build/` в `.gitignore`.
- Триггеры: пуш в `main` → экспорт и деплой на GitHub Pages (Pages в режиме `workflow`); PR → только экспорт; тег `v*` → экспорт и GitHub Release с архивом `memory-web.zip` (содержимое веб-сборки в корне архива).
- Выпуск релиза: `git tag vX.Y.Z && git push origin vX.Y.Z`. Проверено на `v0.0.1`.
- При смене версии Godot обновить `GODOT_VERSION` в workflow.
- Скриншот экрана без прохождения игры (нужен дисплей, снимок 1280×720): `godot --path . -s tests/screenshot.gd -- <id_сцены> <абсолютный_путь.png> [индекс_предмета] [note] [floppy] [fridge]`, например `minigame_clock 1 note` или `minigame_computer 3 floppy` (`note`/`floppy`/`fridge` — подсказка уже найдена на свалке). Писать лучше внутрь проекта (`build/shots/`, в `.gitignore`): flatpak не видит `/tmp` хоста.
