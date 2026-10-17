class_name MinigameTapeView extends MinigameView
## Кассетный плеер: найти и прослушать 3 фрагмента записи.

const TRACK := Rect2(520, 760, 880, 18)
const SPIN: Dictionary = {
	MinigameTapeViewModel.Mode.STOP: 0.0,
	MinigameTapeViewModel.Mode.PLAY: 90.0,
	MinigameTapeViewModel.Mode.FORWARD: 720.0,
	MinigameTapeViewModel.Mode.REWIND: -720.0,
}

var _vm: MinigameTapeViewModel
var _reels: Array[ReelView] = []
var _cursor: ColorRect
var _subtitle: Label
var _marks: Array[ColorRect] = []


func _build() -> void:
	_add_rect(Rect2(0, 0, 1920, 1080), Color("221d19"))
	_add_rect(Rect2(400, 180, 1120, 480), Color("4a4038"))
	_add_rect(Rect2(520, 260, 880, 300), Color("171412"))
	for x in [620, 1010]:
		var reel := ReelView.new()
		reel.position = Vector2(x, 280)
		add_child(reel)
		_reels.append(reel)
	_subtitle = _add_label("", Rect2(400, 590, 1120, 70), 34, Color("f0e6c8"))
	var rewind := _add_glyph_button(GlyphButton.Glyph.REWIND, Rect2(560, 830, 200, 80))
	var play := _add_glyph_button(GlyphButton.Glyph.PLAY, Rect2(800, 830, 200, 80))
	var forward := _add_glyph_button(GlyphButton.Glyph.FORWARD, Rect2(1040, 830, 200, 80))
	var stop := _add_glyph_button(GlyphButton.Glyph.STOP, Rect2(1280, 830, 120, 80))
	_add_rect(TRACK, Color("3a332d"))
	_cursor = _add_rect(Rect2(TRACK.position.x, TRACK.position.y - 12, 6, 42), Color("e6c86a"))
	for i in MinigameTapeViewModel.FRAGMENTS.size():
		_marks.append(_add_rect(Rect2(0, TRACK.position.y + 26, 14, 14), Color("9fd08a")))
		_marks[i].visible = false
	bind(MinigameTapeViewModel.new())
	rewind.button_down.connect(_vm.set_mode.bind(MinigameTapeViewModel.Mode.REWIND))
	rewind.button_up.connect(_vm.set_mode.bind(MinigameTapeViewModel.Mode.STOP))
	forward.button_down.connect(_vm.set_mode.bind(MinigameTapeViewModel.Mode.FORWARD))
	forward.button_up.connect(_vm.set_mode.bind(MinigameTapeViewModel.Mode.STOP))
	play.pressed.connect(_vm.toggle_play)
	stop.pressed.connect(_vm.set_mode.bind(MinigameTapeViewModel.Mode.STOP))


func bind(vm: MinigameTapeViewModel) -> void:
	_vm = vm
	vm.position.changed.connect(_on_position_changed)
	vm.subtitle.changed.connect(func(text: String) -> void: _subtitle.text = text)
	vm.heard_count.changed.connect(func(_v: int) -> void: _refresh_marks())
	vm.solved.connect(_finish)
	_on_position_changed(vm.position.value)


func _process(delta: float) -> void:
	if _vm == null:
		return
	_vm.tick(delta)
	var speed: float = SPIN[_vm.mode.value]
	for reel in _reels:
		reel.rotation += deg_to_rad(speed) * delta


func _on_position_changed(value: float) -> void:
	_cursor.position.x = TRACK.position.x + value * (TRACK.size.x - _cursor.size.x)


func _refresh_marks() -> void:
	for i in _marks.size():
		var fragment := MinigameTapeViewModel.FRAGMENTS[i]
		_marks[i].position.x = TRACK.position.x + (fragment.x + fragment.y) * 0.5 * TRACK.size.x - 7.0
		_marks[i].visible = _vm.is_heard(i)
