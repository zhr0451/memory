class_name JunkyardView extends Control
## Свалка: статичный экран глазами героя. Клик по доступному предмету — зум и переход к мини-игре.

const ITEM_POSITIONS: Array[Vector2] = [
	Vector2(250, 520), Vector2(760, 640), Vector2(1250, 500), Vector2(1560, 650)]
const ZOOM := 1.3
const ZOOM_TIME := 0.9
const SIZE := Vector2(1920, 1080)

var _vm: JunkyardViewModel
var _world: Control
var _items: Array[JunkItemView] = []
var _zoom_from: int = -1
var _busy: bool = false
var _note: JunkNoteView

const NOTE_POSITION := Vector2(1070, 905)


func setup(params: Dictionary) -> void:
	_zoom_from = params.get("zoom_from", -1)


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	clip_contents = true
	_world = Control.new()
	_world.size = SIZE
	_world.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_world)
	_world.add_child(JunkBackdrop.new())
	for i in Story.chapter_count():
		var item := JunkItemView.new()
		item.setup(i, Story.chapter(i).id)
		item.position = ITEM_POSITIONS[i]
		item.pressed.connect(_on_item_pressed)
		_world.add_child(item)
		_items.append(item)
	_add_hidden_note()
	bind(JunkyardViewModel.new(Game.state))
	if _zoom_from >= 0:
		_apply_zoom(_zoom_from, 1.0)
		create_tween().tween_method(func(t: float) -> void: _apply_zoom(_zoom_from, 1.0 - t), 0.0, 1.0, ZOOM_TIME)


func bind(vm: JunkyardViewModel) -> void:
	_vm = vm
	vm.chapter_selected.connect(_on_chapter_selected)
	vm.note_found.connect(_on_note_found)
	vm.chapters_done.changed.connect(func(_v: int) -> void: _refresh())
	_refresh()


func _add_hidden_note() -> void:
	if Game.state.clock_note_found.value:
		return
	_note = JunkNoteView.new()
	_note.position = NOTE_POSITION
	_note.pressed.connect(func() -> void: _vm.find_note())
	_world.add_child(_note)
	var cover := JunkNoteView.Cover.new()
	cover.position = NOTE_POSITION + Vector2(-34, 6)
	_world.add_child(cover)


func _on_note_found() -> void:
	var tween := create_tween().set_parallel()
	tween.tween_property(_note, "position:y", _note.position.y - 90.0, 0.5)
	tween.tween_property(_note, "modulate:a", 0.0, 0.5)
	await tween.finished
	_note.queue_free()


func _refresh() -> void:
	for item in _items:
		item.apply_state(_vm.item_state(item.index))


func _on_item_pressed(index: int) -> void:
	if not _busy:
		_vm.select(index)


func _on_chapter_selected(index: int) -> void:
	_busy = true
	var tween := create_tween()
	tween.tween_method(func(t: float) -> void: _apply_zoom(index, t), 0.0, 1.0, ZOOM_TIME) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	Game.on_chapter_selected(index)


## amount: 0 — общий план, 1 — наезд на предмет.
func _apply_zoom(index: int, amount: float) -> void:
	var zoom := lerpf(1.0, ZOOM, amount)
	var center := _items[index].position + JunkItemView.SIZE * 0.5
	var target := SIZE * 0.5 - center * zoom
	target.x = clampf(target.x, SIZE.x * (1.0 - zoom), 0.0)
	target.y = clampf(target.y, SIZE.y * (1.0 - zoom), 0.0)
	_world.scale = Vector2.ONE * zoom
	_world.position = target
