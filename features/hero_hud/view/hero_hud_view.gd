class_name HeroHudView extends CanvasLayer
## Постоянный интерфейс героя: лицо и батарейка в углу, окошко реплики.
## Реплика печатается по букве, затем держится и сообщает VM, что показана.

const FACE_POS := Vector2(32, 792)
const BATTERY_POS := Vector2(304, 984)
const BOX_POS := Vector2(304, 792)
const BOX_WIDTH := 880.0
const TYPE_SPEED := 0.04
const HOLD_BASE := 1.2
const HOLD_PER_CHAR := 0.03
## Рамка реплики, 9-slice с углами по 32. Без неё — StyleBoxFlat.
const TEXTBOX_PATH := "res://features/hero_hud/assets/ui_textbox.png"
const TEXTBOX_CORNER := 32
const TEXTBOX_INK := Color("2b3320")

var _vm: HeroHudViewModel
var _face: FaceView
var _battery: BatteryView
var _box: PanelContainer
var _label: Label
var _token: int = 0
var _type_tween: Tween


func _ready() -> void:
	layer = 10
	_face = FaceView.new()
	_face.base_position = FACE_POS
	_face.modulate.a = 0.0
	add_child(_face)
	_battery = BatteryView.new()
	_battery.position = BATTERY_POS
	add_child(_battery)
	_build_box()


func bind(vm: HeroHudViewModel) -> void:
	_vm = vm
	vm.emotion.changed.connect(_on_emotion_changed)
	vm.charge.changed.connect(_on_charge_changed)
	vm.face_on.changed.connect(_on_face_on_changed)
	vm.line.changed.connect(_on_line_changed)
	vm.hud_visible.changed.connect(func(on: bool) -> void: visible = on)
	visible = vm.hud_visible.value
	_on_emotion_changed(vm.emotion.value)
	_battery.level = vm.charge.value
	_on_face_on_changed(vm.face_on.value)
	_on_line_changed(vm.line.value)


func _build_box() -> void:
	_box = PanelContainer.new()
	_box.position = BOX_POS
	_box.custom_minimum_size = Vector2(BOX_WIDTH, 0)
	_box.size = Vector2(BOX_WIDTH, 0)
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_box.visible = false
	var textured := ResourceLoader.exists(TEXTBOX_PATH)
	_box.add_theme_stylebox_override("panel", _textbox_style() if textured else _flat_style())
	_label = Label.new()
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.add_theme_font_size_override("font_size", 34)
	if textured:
		_label.add_theme_color_override("font_color", TEXTBOX_INK)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_box.add_child(column)
	column.add_child(_label)
	var skip_hint := Label.new()
	skip_hint.text = Texts.get_text("ui.skip")
	skip_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	skip_hint.modulate.a = 0.5
	skip_hint.add_theme_font_size_override("font_size", 20)
	if textured:
		skip_hint.add_theme_color_override("font_color", TEXTBOX_INK)
	skip_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(skip_hint)
	add_child(_box)


func _textbox_style() -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = load(TEXTBOX_PATH) as Texture2D
	style.set_texture_margin_all(TEXTBOX_CORNER)
	style.set_content_margin_all(28)
	return style


func _flat_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.09, 0.1, 0.13, 0.88)
	style.border_color = Color("8e99a8")
	style.set_border_width_all(3)
	style.set_corner_radius_all(14)
	style.set_content_margin_all(18)
	return style


func _input(event: InputEvent) -> void:
	if _box.visible and AdvanceInput.is_advance(event):
		_skip_line()
		get_viewport().set_input_as_handled()


## Пропуск реплики: сразу следующая (или окно закрывается, если очередь пуста).
func _skip_line() -> void:
	if _type_tween != null:
		_type_tween.kill()
	_token += 1
	_vm.finish_line()


func _on_emotion_changed(kind: int) -> void:
	_face.emotion = kind as Emotion.Kind


## Заряд упал — батарейка мигает, чтобы потерю было видно.
func _on_charge_changed(value: int) -> void:
	var dropped := value < _battery.level
	_battery.level = value
	if dropped:
		var tween := create_tween()
		for alpha in [0.2, 1.0, 0.2, 1.0]:
			tween.tween_property(_battery, "modulate:a", alpha, 0.12)


func _on_face_on_changed(on: bool) -> void:
	var tween := create_tween()
	if on:
		for alpha in [1.0, 0.0, 1.0, 0.2, 1.0]:
			tween.tween_property(_face, "modulate:a", alpha, 0.09)
	else:
		tween.tween_property(_face, "modulate:a", 0.0, 0.6)


func _on_line_changed(text: String) -> void:
	_token += 1
	if text.is_empty():
		_box.visible = false
		return
	_show_line(text, _token)


func _show_line(text: String, token: int) -> void:
	_box.visible = true
	_label.text = text
	_label.visible_ratio = 0.0
	_type_tween = create_tween()
	_type_tween.tween_property(_label, "visible_ratio", 1.0, text.length() * TYPE_SPEED)
	await _type_tween.finished
	await get_tree().create_timer(HOLD_BASE + text.length() * HOLD_PER_CHAR).timeout
	if token == _token:
		_vm.finish_line()
