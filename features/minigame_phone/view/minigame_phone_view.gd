class_name MinigamePhoneView extends MinigameView
## Дисковый телефон: снять трубку, набрать бабушкин номер по рисунку-загадке, считая щелчки.
## Рычаг сбрасывает набор. Арт (mg_phone_*) подставляется, где есть; остальное — заглушки.

const NOTE_REST := Vector2(90, 130)
const RECEIVER_REST := Rect2(640, 110, 640, 110)
const RECEIVER_PATH := "res://features/minigame_phone/assets/mg_phone_receiver.png"
const RINGING_TIME := 2.0
const TEXT_COLOR := Color("f0e6c8")

var _vm: MinigamePhoneViewModel
var _dial: DialView
var _receiver: Button
var _hook: Button
var _status: Label
var _clicks: Label
var _note: PictureNoteView
## Сколько щелчков ждём от текущего возврата диска.
var _expected_pulses: int = 0


func _build() -> void:
	_add_rect(Rect2(0, 0, 1920, 1080), Color("1e1b22"))
	_note = PictureNoteView.new()
	_note.position = NOTE_REST
	_note.rotation = deg_to_rad(-2.0)
	_note.visible = false
	add_child(_note)
	_add_rect(Rect2(600, 180, 720, 760), Color("6a2f2a"))
	_dial = DialView.new()
	_dial.position = Vector2(700, 300)
	add_child(_dial)
	_receiver = _add_button("", RECEIVER_REST, 28)
	_receiver.tooltip_text = Texts.get_text("phone.receiver")
	if ResourceLoader.exists(RECEIVER_PATH):
		_receiver.icon = load(RECEIVER_PATH) as Texture2D
		_receiver.expand_icon = true
	else:
		_receiver.text = Texts.get_text("phone.receiver")
	_hook = _add_button(Texts.get_text("phone.hook"), Rect2(1340, 120, 220, 90), 30)
	_add_rect(Rect2(1380, 300, 480, 420), Color("171412"))
	_status = _add_label("", Rect2(1400, 320, 440, 260), 34, TEXT_COLOR)
	_clicks = _add_label("", Rect2(1400, 590, 440, 110), 30, Color("c8b890"))
	bind(MinigamePhoneViewModel.new(Game.state))


func bind(vm: MinigamePhoneViewModel) -> void:
	_vm = vm
	_receiver.pressed.connect(vm.toggle_receiver)
	_hook.pressed.connect(vm.press_hook)
	_dial.pulled.connect(_on_pulled)
	_dial.pulse.connect(_on_pulse)
	vm.line.changed.connect(func(_v: MinigamePhoneViewModel.Line) -> void: _refresh())
	vm.dialed.changed.connect(func(_v: String) -> void: _refresh())
	vm.solved.connect(_on_solved)
	_refresh()
	vm.activate()
	if vm.note_available():
		_drop_note()


func _refresh() -> void:
	var lifted: bool = _vm.line.value != MinigamePhoneViewModel.Line.HUNG_UP
	var target_y := RECEIVER_REST.position.y - (70.0 if lifted else 0.0)
	create_tween().tween_property(_receiver, "position:y", target_y, 0.2)
	_receiver.rotation = deg_to_rad(-6.0 if lifted else 0.0)
	match _vm.line.value:
		MinigamePhoneViewModel.Line.HUNG_UP:
			_status.text = ""
		MinigamePhoneViewModel.Line.TONE:
			_status.text = Texts.get_text("phone.tone")
		MinigamePhoneViewModel.Line.DIALING:
			_status.text = _dialed_text()
		MinigamePhoneViewModel.Line.RINGING:
			_status.text = "%s\n\n%s" % [_dialed_text(), Texts.get_text("phone.ringing")]
		MinigamePhoneViewModel.Line.BUSY:
			_status.text = "%s\n\n%s" % [_dialed_text(), Texts.get_text("phone.busy")]


## Набранное: «7 4 2 _ _ _».
func _dialed_text() -> String:
	var parts: Array[String] = []
	for i in MinigamePhoneViewModel.NUMBER.length():
		parts.append(_vm.dialed.value[i] if i < _vm.dialed.value.length() else "_")
	return " ".join(parts)


func _on_pulled(digit: int) -> void:
	_expected_pulses = MinigamePhoneViewModel.pulses_for(digit)
	_clicks.text = ""
	_vm.dial(digit)


## Герой считает щелчки вслух: «щёлк-щёлк-щёлк… 3!»
func _on_pulse(count: int) -> void:
	var word := Texts.get_text("phone.click")
	var words: Array[String] = []
	for i in count:
		words.append(word)
	_clicks.text = "-".join(words)
	if count == _expected_pulses:
		_clicks.text += "… %d!" % (count % 10)


func _on_solved() -> void:
	_hook.disabled = true
	await get_tree().create_timer(RINGING_TIME).timeout
	_status.text = Texts.get_text("phone.grandma")
	_status.add_theme_color_override("font_color", Color("9fd08a"))
	await get_tree().create_timer(RINGING_TIME).timeout
	_finish()


## Найденный рисунок с холодильника падает рядом с телефоном.
func _drop_note() -> void:
	_note.visible = true
	_note.position.y = -PictureNoteView.SIZE.y - 40.0
	_note.rotation = deg_to_rad(18.0)
	var tween := create_tween().set_parallel()
	tween.tween_property(_note, "position:y", NOTE_REST.y, 0.9) \
			.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property(_note, "rotation", deg_to_rad(-2.0), 0.9) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
