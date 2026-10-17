class_name MinigameClockView extends MinigameView
## Будильник: кнопками выставить часы и минуты, как на рисунке рядом.

var _vm: MinigameClockViewModel
var _time_label: Label


func _build() -> void:
	_add_rect(Rect2(0, 0, 1920, 1080), Color("1b1a22"))
	_add_rect(Rect2(500, 190, 860, 500), Color("3a3f4b"))
	_add_rect(Rect2(540, 230, 780, 220), Color("171a16"))
	_time_label = _add_label("", Rect2(540, 230, 780, 220), 170, Color("c8d3b0"))
	var hours_up := _add_glyph_button(GlyphButton.Glyph.UP, Rect2(600, 490, 180, 70))
	var hours_down := _add_glyph_button(GlyphButton.Glyph.DOWN, Rect2(600, 580, 180, 70))
	var minutes_up := _add_glyph_button(GlyphButton.Glyph.UP, Rect2(1080, 490, 180, 70))
	var minutes_down := _add_glyph_button(GlyphButton.Glyph.DOWN, Rect2(1080, 580, 180, 70))
	_add_label("часы", Rect2(780, 520, 140, 60), 28, Color("aab2c2"))
	_add_label("мин", Rect2(1260, 520, 100, 60), 28, Color("aab2c2"))
	var paper := _add_rect(Rect2(1440, 240, 320, 400), Color("efe3c8"))
	paper.pivot_offset = paper.size * 0.5
	paper.rotation = deg_to_rad(-3.0)
	var hint := Label.new()
	hint.text = Texts.get_text("clock.hint")
	hint.size = paper.size
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 96)
	hint.add_theme_color_override("font_color", Color("c0483a"))
	paper.add_child(hint)
	bind(MinigameClockViewModel.new())
	hours_up.pressed.connect(_vm.change_hours.bind(1))
	hours_down.pressed.connect(_vm.change_hours.bind(-1))
	minutes_up.pressed.connect(_vm.change_minutes.bind(1))
	minutes_down.pressed.connect(_vm.change_minutes.bind(-1))


func bind(vm: MinigameClockViewModel) -> void:
	_vm = vm
	vm.hours.changed.connect(func(_v: int) -> void: _refresh())
	vm.minutes.changed.connect(func(_v: int) -> void: _refresh())
	vm.solved.connect(_on_solved)
	_refresh()


func _refresh() -> void:
	_time_label.text = _vm.time_text()


func _on_solved() -> void:
	var tween := create_tween().set_loops(6)
	tween.tween_property(_time_label, "modulate", Color(1.0, 0.5, 0.4), 0.08)
	tween.tween_property(_time_label, "modulate", Color.WHITE, 0.08)
	_finish()
