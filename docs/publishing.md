# Публикация: itch.io и Ludum Dare

Сборка: `tools/export_web.sh ~/Downloads/on-menya-naydet-web.zip` — zip с `index.html` в корне, подходит обоим сайтам (подробности в [tooling.md](tooling.md)).

## Ludum Dare 60
На LD60 загрузка файлов на сайт выключена для всего события (у события `can-upload=0`), поэтому в редакторе нет раздела Embedding. Играть на LD можно только по ссылке: игра лежит на itch.io, ссылка — в Links.

Страница игры: <https://ldjam.com/events/ludum-dare/60/$435169> → кнопка Edit (`/edit`). Сохраняется сама (в сайдбаре «Saved»).

1. **Title, Description** — название и описание (сейчас «Work in progress»). Скриншоты — через Upload Image над описанием.
2. **Cover Image** → Upload, 640×512 (5:4).
3. **Links** → Platform «HTML5 (web)», URL — страница игры на itch.io. Ссылку на код можно добавить через Add (Platform «Source Code»).
4. **Rating Category Opt-outs** — отмечать, только если графику или звук делали не во время джема. Сейчас ничего не отмечено.
5. **Submission Checklist** — три галочки (уже стоят).
6. **Event Format** — Jam (уже выбран).
7. **Publish** в сайдбаре.

Если организаторы включат загрузку (появится раздел Embedding): Upload → тот же zip. Embed — iframe 948×533 без IndexedDB и localStorage; сборка это выдерживает, только выбор языка не сохраняется между перезагрузками.

## itch.io
1. <https://itch.io/game/new>.
2. **Kind of project** — HTML.
3. **Uploads** → Upload files → zip → отметить «This file will be played in the browser».
4. **Embed options**: Embed in page, 960×540 (игра подстраивается под размер окна); включить Fullscreen button. Mobile friendly не отмечать. SharedArrayBuffer не нужен (потоки в сборке выключены).
5. Обложка 630×500, скриншоты, жанр, теги.
6. **Visibility** — Public (или сначала Draft, чтобы проверить). Save.
7. Открыть страницу, нажать Run game и пройти первые сцены.
8. Ссылку на страницу игры вставить в Links на LD.
