class_name MinigameComputerView extends MinigameView
## Старый компьютер: два выключателя, дискета в дисковод, пароль с экранной клавиатуры.
## После входа на экране файл «ПЕРЕЕЗД.TXT»; кнопка «Выключить» завершает мини-игру.
## Арт (mg_computer_*) пока не подключён: всё рисуется заглушками.

const SCREEN_RECT := Rect2(580, 70, 700, 400)
const SLOT_RECT := Rect2(1500, 250, 280, 36)
const FLOPPY_REST := Vector2(150, 300)
const KEY_SIZE := Vector2(64, 60)
const KEY_GAP := 6.0
const KEYS_ORIGIN := Vector2(500, 580)
const SCREEN_ON := Color("1d2a22")
const SCREEN_DARK := Color("0b0d0c")
const TEXT_COLOR := Color("9fe0a8")

var _vm: MinigameComputerViewModel
var _screen: ColorRect
var _screen_text: Label
var _pc_button: Button
var _monitor_button: Button
var _floppy: FloppyView
var _slot: ColorRect
var _shutdown: Button
var _wrong: bool = false


func _build() -> void:
	_add_rect(Rect2(0, 0, 1920, 1080), Color("1c1b20"))
	_add_rect(Rect2(0, 760, 1920, 320), Color("2a2622"))
	_add_rect(Rect2(520, 30, 820, 500), Color("b9b2a0"))
	_screen = _add_rect(SCREEN_RECT, SCREEN_DARK)
	_screen.pivot_offset = SCREEN_RECT.size * 0.5
	_screen_text = Label.new()
	_screen_text.position = Vector2(28, 24)
	_screen_text.size = SCREEN_RECT.size - Vector2(56, 48)
	_screen_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_screen_text.add_theme_font_size_override("font_size", 30)
	_screen_text.add_theme_color_override("font_color", TEXT_COLOR)
	_screen.add_child(_screen_text)
	_monitor_button = _add_toggle(Texts.get_text("computer.monitor"), Rect2(1040, 478, 280, 44))
	_add_rect(Rect2(1460, 100, 360, 620), Color("c4bdab"))
	_slot = _add_rect(SLOT_RECT, Color("2b2a28"))
	_add_label(Texts.get_text("computer.slot"), Rect2(1480, 290, 320, 40), 24, Color("4a463d"))
	_pc_button = _add_toggle(Texts.get_text("computer.power"), Rect2(1500, 560, 280, 80))
	_build_keyboard()
	_shutdown = _add_button(Texts.get_text("computer.shutdown"), Rect2(1460, 760, 360, 100), 40)
	_shutdown.visible = false
	_floppy = FloppyView.new()
	_floppy.position = FLOPPY_REST
	_floppy.dropped.connect(_on_floppy_dropped)
	add_child(_floppy)
	bind(MinigameComputerViewModel.new(Game.state, Texts.language == "ru", Texts.get_text("computer.password")))


func bind(vm: MinigameComputerViewModel) -> void:
	_vm = vm
	_pc_button.pressed.connect(_vm.toggle_pc)
	_monitor_button.pressed.connect(_vm.toggle_monitor)
	_shutdown.pressed.connect(_on_shutdown)
	vm.pc_on.changed.connect(func(on: bool) -> void: _pc_button.set_pressed_no_signal(on))
	vm.monitor_on.changed.connect(func(on: bool) -> void: _monitor_button.set_pressed_no_signal(on))
	vm.screen.changed.connect(_on_screen_changed)
	vm.password.changed.connect(func(_v: String) -> void: _refresh_text())
	vm.floppy_in.changed.connect(func(_v: bool) -> void: _refresh_text())
	vm.submitted.connect(func(ok: bool) -> void:
		_wrong = not ok
		_refresh_text())
	vm.solved.connect(func() -> void: _shutdown.visible = true)
	_floppy.visible = vm.floppy_available()
	_refresh_text()


func _add_toggle(text: String, rect: Rect2) -> Button:
	var button := _add_button(text, rect, 28)
	button.toggle_mode = true
	return button


func _build_keyboard() -> void:
	var rows := MinigameComputerViewModel.ROWS
	_add_rect(Rect2(KEYS_ORIGIN - Vector2(24, 18), Vector2(950, 3 * (KEY_SIZE.y + KEY_GAP) + 30)), Color("b9b2a0"))
	for row in rows.size():
		var shift := row * 24.0
		for column in (rows[row] as Array).size():
			var pos := KEYS_ORIGIN + Vector2(shift + column * (KEY_SIZE.x + KEY_GAP), row * (KEY_SIZE.y + KEY_GAP))
			var key := _add_button(MinigameComputerViewModel.key_label(row, column), Rect2(pos, KEY_SIZE), 20)
			key.pressed.connect(func() -> void: _vm.press_key(row, column))
	var right := KEYS_ORIGIN.x + 12 * (KEY_SIZE.x + KEY_GAP)
	var backspace := _add_button(Texts.get_text("computer.backspace"), Rect2(right - 50, KEYS_ORIGIN.y + KEY_SIZE.y + KEY_GAP, 120, KEY_SIZE.y), 20)
	backspace.pressed.connect(func() -> void: _vm.backspace())
	var enter := _add_button(Texts.get_text("computer.enter"), Rect2(right - 50, KEYS_ORIGIN.y + 2 * (KEY_SIZE.y + KEY_GAP), 120, KEY_SIZE.y), 20)
	enter.pressed.connect(func() -> void: _vm.enter())


func _on_floppy_dropped(at: Vector2) -> void:
	if SLOT_RECT.grow(60.0).has_point(at):
		_vm.insert_floppy()
	if _vm.floppy_in.value:
		_floppy.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var tween := create_tween().set_parallel()
		tween.tween_property(_floppy, "position", SLOT_RECT.get_center() - FloppyView.SIZE * Vector2(0.5, 0.2), 0.25)
		tween.tween_property(_floppy, "modulate:a", 0.0, 0.35).set_delay(0.15)
	else:
		create_tween().tween_property(_floppy, "position", FLOPPY_REST, 0.3).set_trans(Tween.TRANS_BACK)


## Монитор «прогревается»: картинка проявляется из полоски.
func _on_screen_changed(screen: MinigameComputerViewModel.Screen) -> void:
	var was_dark := _screen.color == SCREEN_DARK
	_screen.color = SCREEN_DARK if screen == MinigameComputerViewModel.Screen.OFF else SCREEN_ON
	if was_dark and screen != MinigameComputerViewModel.Screen.OFF:
		_screen.scale = Vector2(1.0, 0.02)
		create_tween().tween_property(_screen, "scale", Vector2.ONE, 0.6).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	_wrong = false
	_refresh_text()


func _refresh_text() -> void:
	match _vm.screen.value:
		MinigameComputerViewModel.Screen.OFF:
			_screen_text.text = ""
		MinigameComputerViewModel.Screen.NO_SIGNAL:
			_screen_text.text = Texts.get_text("computer.no_signal")
		MinigameComputerViewModel.Screen.NO_DISK:
			_screen_text.text = Texts.get_text("computer.no_disk")
		MinigameComputerViewModel.Screen.PASSWORD:
			var lines: Array[String] = [
				Texts.get_text("computer.login"),
				Texts.get_text("computer.hint"),
				"",
				"%s %s_" % [Texts.get_text("computer.prompt"), _vm.password.value],
			]
			if _wrong:
				lines.append(Texts.get_text("computer.wrong"))
			_screen_text.text = "\n".join(lines)
		MinigameComputerViewModel.Screen.DESKTOP:
			var file: Array[String] = [Texts.get_text("computer.file.title"), ""]
			for i in 4:
				file.append(Texts.get_text("computer.file.%d" % (i + 1)))
			_screen_text.text = "\n".join(file)


func _on_shutdown() -> void:
	_shutdown.disabled = true
	create_tween().tween_property(_screen, "scale", Vector2(1.0, 0.01), 0.4).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	_finish()


## Дискета на столе: её перетаскивают мышью в щель дисковода.
class FloppyView extends Control:
	signal dropped(at: Vector2)

	const SIZE := Vector2(150, 150)
	const PATH := "res://features/minigame_computer/assets/mg_computer_floppy.png"

	var _texture: Texture2D
	var _dragging: bool = false
	var _grab: Vector2

	func _ready() -> void:
		size = SIZE
		custom_minimum_size = SIZE
		mouse_default_cursor_shape = Control.CURSOR_DRAG
		_texture = load(PATH) if ResourceLoader.exists(PATH) else null

	func _gui_input(event: InputEvent) -> void:
		var button := event as InputEventMouseButton
		if button != null and button.button_index == MOUSE_BUTTON_LEFT:
			if button.pressed:
				_dragging = true
				_grab = button.position
			elif _dragging:
				_dragging = false
				dropped.emit(position + size * 0.5)
		var motion := event as InputEventMouseMotion
		if motion != null and _dragging:
			position += motion.position - _grab

	func _draw() -> void:
		if _texture != null:
			draw_texture_rect(_texture, Rect2(Vector2.ZERO, size), false)
			return
		draw_rect(Rect2(Vector2.ZERO, size), Color("3d4250"))
		draw_rect(Rect2(Vector2.ZERO, size), Color("272b35"), false, 3.0)
		draw_rect(Rect2(40, 0, 70, 46), Color("9aa0ab"))
		draw_rect(Rect2(24, 74, 102, 66), Color("c9c5b8"))
