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

var _vm: HeroHudViewModel
var _face: FaceView
var _battery: BatteryView
var _box: PanelContainer
var _label: Label
var _token: int = 0


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
	vm.battery.changed.connect(_on_battery_changed)
	vm.face_on.changed.connect(_on_face_on_changed)
	vm.line.changed.connect(_on_line_changed)
	_on_emotion_changed(vm.emotion.value)
	_on_battery_changed(vm.battery.value)
	_on_face_on_changed(vm.face_on.value)
	_on_line_changed(vm.line.value)


func _build_box() -> void:
	_box = PanelContainer.new()
	_box.position = BOX_POS
	_box.custom_minimum_size = Vector2(BOX_WIDTH, 0)
	_box.size = Vector2(BOX_WIDTH, 0)
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_box.visible = false
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.09, 0.1, 0.13, 0.88)
	style.border_color = Color("8e99a8")
	style.set_border_width_all(3)
	style.set_corner_radius_all(14)
	style.set_content_margin_all(18)
	_box.add_theme_stylebox_override("panel", style)
	_label = Label.new()
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.add_theme_font_size_override("font_size", 34)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_box.add_child(_label)
	add_child(_box)


func _on_emotion_changed(kind: int) -> void:
	_face.emotion = kind as Emotion.Kind


func _on_battery_changed(value: int) -> void:
	_battery.level = value


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
	var tween := create_tween()
	tween.tween_property(_label, "visible_ratio", 1.0, text.length() * TYPE_SPEED)
	await tween.finished
	await get_tree().create_timer(HOLD_BASE + text.length() * HOLD_PER_CHAR).timeout
	if token == _token:
		_vm.finish_line()
