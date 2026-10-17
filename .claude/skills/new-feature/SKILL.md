---
name: new-feature
description: Создать новую фичу Godot-проекта по MVVM и feature-first (папка features/<name> с моделью, ViewModel, View и сценой), всё кодом. Используй, когда просят добавить фичу/экран/механику.
---

# new-feature

Аргумент: имя фичи в `snake_case` (например `card_board`).

1. Прочитай `docs/architecture.md` и `docs/conventions.md`.
2. Создай структуру `features/<name>/{model,viewmodel,view,assets,tests}`.
3. Напиши, по шаблону ниже:
   - `model/<name>_model.gd` — `class_name <Pascal>Model extends RefCounted`, без Node.
   - `viewmodel/<name>_view_model.gd` — `extends ViewModel`, поля `Observable`, команды-методы.
   - `view/<name>_view.gd` — `extends Control`, `bind(vm)` подписывается на `changed` и обновляет узлы.
   - `<name>.tscn` — текстовая сцена с корневым View-скриптом.
4. Не редактируй сцену через редактор; правь `.tscn` текстом.
5. Проверь: `godot --headless --path . --import` (парсинг скриптов/ресурсов; ошибки видны в выводе) без ошибок парсинга.

Шаблон View:
```gdscript
class_name CardBoardView extends Control

var _vm: CardBoardViewModel

func bind(vm: CardBoardViewModel) -> void:
	_vm = vm
	vm.score.changed.connect(_on_score_changed)
	_on_score_changed(vm.score.value)

func _on_score_changed(value: int) -> void:
	%ScoreLabel.text = str(value)
```
