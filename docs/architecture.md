# Архитектура: MVVM + feature-first

## Слои
| Слой | Тип | Ответственность | Запрещено |
|---|---|---|---|
| Model | `Resource` / `RefCounted` | данные и доменные правила | `Node`, `get_node`, UI |
| ViewModel | `RefCounted` (extends `ViewModel`) | состояние для UI (`Observable`), команды (методы), логика представления | ссылки на `Node`, сцену, `Input` |
| View | `Node`/`Control` + скрипт | привязка к VM, отображение, ввод → вызов команд VM | игровая логика |

Поток данных: ввод → View вызывает метод VM → VM меняет Model/Observable → View получает сигнал `changed` и обновляет узлы.

## Observable
`core/mvvm/observable.gd` — обёртка значения с сигналом `changed(new_value)`. View подписывается в `_ready()` и отписывается автоматически при `queue_free` (используйте `connect` на объекты с тем же жизненным циклом или `CONNECT_REFERENCE_COUNTED` при необходимости). Начальное значение отрисовывается явным вызовом обработчика.

## Feature-first
```
features/<feature>/
  <feature>.tscn          корневая сцена View
  model/                  Resource/RefCounted
  viewmodel/<feature>_view_model.gd
  view/<feature>_view.gd  (+ подсцены)
  assets/                 ассеты только этой фичи
  tests/
```
- Фича самодостаточна: удаление папки не должно ломать другие фичи (кроме явно подключающих её точек входа).
- Межфичевое взаимодействие: сигналы/шина в `core/`, либо корневой VM передаёт зависимости в дочерние (dependency injection через `setup(...)`).
- Сцены собираются из View-скриптов, VM создаётся и передаётся View через `bind(view_model)`.

## Создание сцен кодом
Сцены пишем как текстовые `.tscn` (или собираем из GDScript через `PackedScene.pack`). Узлы, на которые ссылается скрипт, помечаем unique name (`%Name`).
