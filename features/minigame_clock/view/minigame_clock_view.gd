class_name MinigameClockView extends MinigameView
## Будильник: из записки вывести время подъёма, выставить часы, минуты, утро/вечер и дни, нажать «Завести».

var _vm: MinigameClockViewModel
var _face: ClockFaceView
var _lcd: Label
var _period: Button
var _day_buttons: Array[Button] = []
var _hour_knob: Knob
var _minute_knob: Knob
var _result: Label


func _build() -> void:
	_add_rect(Rect2(0, 0, 1920, 1080), Color("1b1a22"))
	_build_note()
	_add_rect(Rect2(480, 90, 1000, 880), Color("3a3f4b"))
	_face = ClockFaceView.new()
	_face.position = Vector2(520, 140)
	add_child(_face)
	_add_rect(Rect2(950, 150, 480, 140), Color("171a16"))
	_lcd = _add_label("", Rect2(950, 150, 480, 140), 120, Color("c8d3b0"))
	_period = _add_button("", Rect2(950, 320, 480, 80), 40)
	for i in 7:
		var day := _add_button(Texts.get_text("day.%d" % (i + 1)), Rect2(950 + i * 76, 430, 70, 70), 24)
		day.toggle_mode = true
		_day_buttons.append(day)
	_hour_knob = Knob.new()
	_hour_knob.position = Vector2(560, 590)
	add_child(_hour_knob)
	_minute_knob = Knob.new()
	_minute_knob.position = Vector2(780, 590)
	add_child(_minute_knob)
	_add_label(Texts.get_text("clock.hours"), Rect2(540, 760, 200, 50), 32, Color("c5ccd8"))
	_add_label(Texts.get_text("clock.minutes"), Rect2(760, 760, 200, 50), 32, Color("c5ccd8"))
	_result = _add_label("", Rect2(950, 640, 480, 100), 36)
	var wind := _add_button(Texts.get_text("clock.submit"), Rect2(1010, 770, 360, 110), 44)
	bind(MinigameClockViewModel.new())
	wind.pressed.connect(_vm.submit)


func bind(vm: MinigameClockViewModel) -> void:
	_vm = vm
	_hour_knob.angle_changed.connect(func(degrees: float) -> void:
		_vm.set_hour(MinigameClockViewModel.hour_from_angle(degrees))
		_hour_knob.angle = (_vm.hour.value % 12) * 30.0 - 90.0)
	_minute_knob.angle_changed.connect(func(degrees: float) -> void:
		_vm.set_minute(MinigameClockViewModel.minute_from_angle(degrees))
		_minute_knob.angle = _vm.minute.value * 6.0 - 90.0)
	_period.pressed.connect(func() -> void: _vm.set_pm(not _vm.pm.value))
	for i in _day_buttons.size():
		_day_buttons[i].pressed.connect(_vm.toggle_day.bind(i))
	vm.hour.changed.connect(func(_v: int) -> void: _refresh())
	vm.minute.changed.connect(func(_v: int) -> void: _refresh())
	vm.pm.changed.connect(func(_v: bool) -> void: _refresh())
	vm.days.changed.connect(func(_v: int) -> void: _refresh())
	vm.submitted.connect(_on_submitted)
	vm.solved.connect(_on_solved)
	_hour_knob.angle = (vm.hour.value % 12) * 30.0 - 90.0
	_minute_knob.angle = vm.minute.value * 6.0 - 90.0
	_refresh()


func _build_note() -> void:
	var paper := _add_rect(Rect2(60, 130, 380, 630), Color("efe3c8"))
	paper.pivot_offset = paper.size * 0.5
	paper.rotation = deg_to_rad(-3.0)
	var lines: Array[String] = [Texts.get_text("clock.note.title")]
	for i in 4:
		lines.append(Texts.get_text("clock.note.%d" % (i + 1)))
	var note := Label.new()
	note.text = "\n\n".join(lines)
	note.position = Vector2(24, 24)
	note.size = Vector2(paper.size.x - 48, paper.size.y - 48)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_font_size_override("font_size", 28)
	note.add_theme_color_override("font_color", Color("5a3d2a"))
	paper.add_child(note)


func _refresh() -> void:
	_face.hour = _vm.hour.value
	_face.minute = _vm.minute.value
	_lcd.text = _vm.time_text()
	_period.text = Texts.get_text("clock.pm" if _vm.pm.value else "clock.am")
	for i in _day_buttons.size():
		_day_buttons[i].set_pressed_no_signal(_vm.is_day_on(i))


func _on_submitted(correct: bool) -> void:
	_result.text = Texts.get_text("clock.right" if correct else "clock.wrong")
	_result.add_theme_color_override("font_color", Color("9fd08a") if correct else Color("e0a060"))


func _on_solved() -> void:
	var tween := create_tween().set_loops(8)
	tween.tween_property(_lcd, "modulate", Color(1.0, 0.5, 0.4), 0.08)
	tween.tween_property(_lcd, "modulate", Color.WHITE, 0.08)
	_finish()
