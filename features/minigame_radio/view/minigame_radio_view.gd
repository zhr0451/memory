class_name MinigameRadioView extends MinigameView
## Магнитола: ручка настройки, шкала силы сигнала, кассеты и кнопка «Готово».
## При верной настройке и кассете включается запись.

const METER_LEDS := 10
const RECORDING_KEYS: Array[String] = ["tape.1", "tape.2", "tape.3"]
const RECORDING_LINE_TIME := 3.2
const GARBLE_INTERVAL := 0.07
const NOISE_LENGTH := 60

var _vm: MinigameRadioViewModel
var _knob: Knob
var _lcd: Label
var _wave: WaveScreen
var _garble_timer: float = 0.0
var _speech: Label
var _leds: Array[ColorRect] = []
var _cassette_buttons: Array[Button] = []
var _deck_label: Label
var _reels: Array[ReelView] = []
var _result: Label
var _playing: bool = false


func _build() -> void:
	_add_rect(Rect2(0, 0, 1920, 1080), Color("221d19"))
	_add_rect(Rect2(300, 90, 1320, 640), Color("4a4038"))
	_wave = WaveScreen.new()
	_wave.position = Vector2(360, 140)
	_wave.size = Vector2(400, 120)
	add_child(_wave)
	_lcd = _add_label("", Rect2(640, 225, 110, 30), 24, Color("8fa07a"))
	_lcd.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	for i in METER_LEDS:
		_leds.append(_add_rect(Rect2(360 + i * 40, 290, 32, 36), Color("2a2622")))
	_add_rect(Rect2(820, 140, 740, 240), Color("171412"))
	_speech = _add_label("", Rect2(840, 150, 700, 220), 38, Color("f0e6c8"))
	_knob = Knob.new()
	_knob.position = Vector2(440, 400)
	add_child(_knob)
	_add_label(Texts.get_text("radio.dial"), Rect2(420, 570, 200, 50), 30, Color("c5ccd8"))
	_add_label(Texts.get_text("radio.controls"), Rect2(310, 630, 460, 90), 26, Color("8e99a8"))
	_add_rect(Rect2(820, 420, 740, 270), Color("2e2824"))
	for x in [900, 1260]:
		var reel := ReelView.new()
		reel.position = Vector2(x, 450)
		reel.scale = Vector2.ONE * 0.8
		add_child(reel)
		_reels.append(reel)
	_deck_label = _add_label("", Rect2(1020, 620, 360, 60), 36, Color("f0e6c8"))
	for i in MinigameRadioViewModel.CASSETTE_COUNT:
		var button := _add_button(Texts.get_text("cassette.%d" % (i + 1)), Rect2(300 + i * 340, 780, 300, 100), 38)
		button.toggle_mode = true
		_cassette_buttons.append(button)
	_result = _add_label("", Rect2(460, 920, 820, 90), 36)
	var done := _add_button(Texts.get_text("ui.done"), Rect2(1300, 920, 320, 100), 44)
	bind(MinigameRadioViewModel.new())
	done.pressed.connect(_vm.submit)


func bind(vm: MinigameRadioViewModel) -> void:
	_vm = vm
	_knob.angle = MinigameRadioViewModel.angle_for(vm.frequency.value)
	_knob.angle_changed.connect(vm.set_angle)
	for i in _cassette_buttons.size():
		_cassette_buttons[i].pressed.connect(vm.insert_cassette.bind(i))
	vm.frequency.changed.connect(func(_v: float) -> void: _refresh())
	vm.strength.changed.connect(func(_v: float) -> void: _refresh())
	vm.heard_text.changed.connect(func(_v: String) -> void: _refresh())
	vm.cassette.changed.connect(func(_v: int) -> void: _refresh())
	vm.submitted.connect(_on_submitted)
	vm.solved.connect(_on_solved)
	_refresh()


func _input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed:
		return
	if key.keycode == KEY_LEFT or key.keycode == KEY_RIGHT:
		_vm.nudge(-1 if key.keycode == KEY_LEFT else 1)
		get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if _playing:
		for reel in _reels:
			reel.rotation += deg_to_rad(90.0) * delta
		return
	_garble_timer -= delta
	if _garble_timer <= 0.0:
		_garble_timer = GARBLE_INTERVAL
		_speech.text = _heard_now()


## Что на экране сейчас: непойманные символы — случайные цифры, каждый раз новые.
func _heard_now() -> String:
	var text: String = _vm.heard_text.value
	if text.is_empty():
		return MinigameRadioViewModel.garble("x".repeat(NOISE_LENGTH), 0.0)
	return MinigameRadioViewModel.garble(text, _vm.strength.value)


func _refresh() -> void:
	_lcd.text = "%.1f" % _vm.frequency.value
	_knob.angle = MinigameRadioViewModel.angle_for(_vm.frequency.value)
	_wave.strength = _vm.strength.value
	_wave.cycles = _vm.wave_cycles
	var lit := int(round(_vm.strength.value * METER_LEDS))
	for i in _leds.size():
		_leds[i].color = Color("9fd08a") if i < lit else Color("2a2622")
	for i in _cassette_buttons.size():
		_cassette_buttons[i].set_pressed_no_signal(i == _vm.cassette.value)
	var inserted: int = _vm.cassette.value
	_deck_label.text = Texts.get_text("cassette.%d" % (inserted + 1)) if inserted >= 0 else ""


func _on_submitted(correct: bool) -> void:
	_result.text = Texts.get_text("radio.right" if correct else "radio.wrong")
	_result.add_theme_color_override("font_color", Color("9fd08a") if correct else Color("e0a060"))


func _on_solved() -> void:
	_playing = true
	for key in RECORDING_KEYS:
		_speech.text = Texts.get_text(key)
		await get_tree().create_timer(RECORDING_LINE_TIME).timeout
	_finish()
