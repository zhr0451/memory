class_name JunkyardView extends Control
## Свалка: статичный экран глазами героя. Клик по доступному предмету — зум и переход к мини-игре.
## Сам предмет не подсвечен: найти его помогает сканер в правом нижнем углу.

## Места предметов в куче (левый верхний угол, холст 1920×1080). Телефон и камера — на будущее.
const ITEM_POSITIONS: Dictionary = {
	&"projector": Vector2(1464, 558),
	&"phone": Vector2(630, 769),
	&"clock": Vector2(229, 649),
	&"radio": Vector2(937, 709),
	&"computer": Vector2(1612, 879),
	&"camera": Vector2(1500, 330),
}
## Спрятанные подсказки и кучи, которые их прикрывают.
const CLUE_POSITIONS: Dictionary = {
	JunkyardViewModel.Clue.NOTE: Vector2(1706, 666),
	JunkyardViewModel.Clue.FLOPPY: Vector2(1002, 976),
	JunkyardViewModel.Clue.FRIDGE: Vector2(1350, 887),
}
const COVER_OFFSETS: Dictionary = {
	JunkyardViewModel.Clue.NOTE: Vector2(-34, 6),
	JunkyardViewModel.Clue.FLOPPY: Vector2(-150, 2),
	JunkyardViewModel.Clue.FRIDGE: Vector2(40, 90),
}
const ZOOM := 1.3
const ZOOM_TIME := 0.9
const SIZE := Vector2(1920, 1080)

var _vm: JunkyardViewModel
var _world: Control
var _items: Array[JunkItemView] = []
var _zoom_from: int = -1
var _busy: bool = false
var _clues: Dictionary = {}
var _overlay: ScanOverlay
var _scanner: ScannerButton


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
	for i in Story.item_count():
		var item := JunkItemView.new()
		item.setup(i, Story.item(i).id)
		item.position = ITEM_POSITIONS[Story.item(i).id]
		item.pressed.connect(_on_item_pressed)
		_world.add_child(item)
		_items.append(item)
	_overlay = ScanOverlay.new()
	add_child(_overlay)
	_scanner = ScannerButton.new()
	_scanner.pressed.connect(start_scan)
	add_child(_scanner)
	var vm := JunkyardViewModel.new(Game.state)
	for clue: JunkyardViewModel.Clue in CLUE_POSITIONS:
		_add_hidden_clue(vm, clue)
	bind(vm)
	if _zoom_from >= 0:
		_apply_zoom(_zoom_from, 1.0)
		create_tween().tween_method(func(t: float) -> void: _apply_zoom(_zoom_from, 1.0 - t), 0.0, 1.0, ZOOM_TIME)


func bind(vm: JunkyardViewModel) -> void:
	_vm = vm
	vm.item_selected.connect(_on_item_selected)
	vm.clue_found.connect(_on_clue_found)
	vm.scan_started.connect(_on_scan_started)
	_overlay.finished.connect(vm.end_scan)
	vm.items_done.changed.connect(func(_v: int) -> void: _refresh())
	_refresh()


## Клик по кнопке сканера.
func start_scan() -> void:
	if _busy:
		return
	if not _vm.scan() and not _vm.scanning.value:
		_scanner.show_refused()


func _on_scan_started(index: int) -> void:
	_scanner.show_pulse()
	var target := Rect2()
	if index >= 0:
		var rect := _items[index].get_global_rect()
		target = Rect2(rect.position - global_position, rect.size)
	_overlay.pulse(_scanner.position + _scanner.size * 0.5, target)


func _add_hidden_clue(vm: JunkyardViewModel, clue: JunkyardViewModel.Clue) -> void:
	if vm.is_clue_found(clue):
		return
	var view := JunkNoteView.create(clue)
	view.position = CLUE_POSITIONS[clue]
	view.pressed.connect(func() -> void: _vm.find_clue(clue))
	_world.add_child(view)
	_clues[clue] = view
	if JunkNoteView.has_art(clue):
		return
	var cover := JunkNoteView.Cover.new()
	cover.position = CLUE_POSITIONS[clue] + COVER_OFFSETS[clue]
	_world.add_child(cover)


func _on_clue_found(clue: JunkyardViewModel.Clue) -> void:
	var view: JunkNoteView = _clues[clue]
	_clues.erase(clue)
	var tween := create_tween().set_parallel()
	tween.tween_property(view, "position:y", view.position.y - 90.0, 0.5)
	tween.tween_property(view, "modulate:a", 0.0, 0.5)
	await tween.finished
	view.queue_free()


func _refresh() -> void:
	for item in _items:
		item.apply_state(_vm.item_state(item.index))


func _on_item_pressed(index: int) -> void:
	if not _busy:
		_vm.select(index)


func _on_item_selected(index: int) -> void:
	_busy = true
	if _vm.scanning.value:
		_overlay.stop(0.25)
	var tween := create_tween()
	tween.tween_method(func(t: float) -> void: _apply_zoom(index, t), 0.0, 1.0, ZOOM_TIME) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	Game.on_item_selected(index)


## amount: 0 — общий план, 1 — наезд на предмет.
func _apply_zoom(index: int, amount: float) -> void:
	var zoom := lerpf(1.0, ZOOM, amount)
	var center := _items[index].position + JunkItemView.SIZE * 0.5
	var target := SIZE * 0.5 - center * zoom
	target.x = clampf(target.x, SIZE.x * (1.0 - zoom), 0.0)
	target.y = clampf(target.y, SIZE.y * (1.0 - zoom), 0.0)
	_world.scale = Vector2.ONE * zoom
	_world.position = target
