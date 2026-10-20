class_name ScanOverlay extends ColorRect
## Фильтр режима сканера поверх свалки (шейдер scan.gdshader) и рамки-прицелы вокруг предмета и подсказки к нему.
## Импульс: экран зеленеет, волна бежит от сканера, предмет проявляется; через DURATION всё гаснет.

signal finished

const SHADER := preload("res://features/junkyard/view/scan.gdshader")
const DURATION := 3.0
const FADE_IN := 0.35
const FADE_OUT := 0.5
const WAVE_TIME := 1.3
const WAVE_END := 2300.0
const MARK_COLOR := Color(0.55, 1.0, 0.7)
## Параметры шейдера под прямоугольники: предмет, подсказка.
const PARAMS: Array[StringName] = [&"target", &"clue_target"]

var strength: float = 0.0:
	set(value):
		strength = value
		_material.set_shader_parameter("strength", value)
		visible = value > 0.0
var wave: float = 0.0:
	set(value):
		wave = value
		_material.set_shader_parameter("wave", value)
		_update_mark()

var _material := ShaderMaterial.new()
var _targets: Array[Rect2] = []
var _marks: Array[Control] = []
var _tween: Tween


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_material.shader = SHADER
	material = _material
	for i in PARAMS.size():
		var mark := Control.new()
		mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
		mark.draw.connect(_draw_mark.bind(mark))
		add_child(mark)
		_marks.append(mark)
	strength = 0.0


## origin — откуда идёт волна, targets — до двух прямоугольников (предмет, подсказка) в координатах экрана.
func pulse(origin: Vector2, targets: Array[Rect2]) -> void:
	_targets = targets
	_material.set_shader_parameter("origin", origin)
	_material.set_shader_parameter("canvas_size", size)
	for i in PARAMS.size():
		var target: Rect2 = targets[i] if i < targets.size() else Rect2()
		_material.set_shader_parameter(PARAMS[i], Vector4(target.position.x, target.position.y, target.size.x, target.size.y))
		_marks[i].position = target.position
		_marks[i].size = target.size
		_marks[i].modulate.a = 0.0
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "strength", 1.0, FADE_IN).from(strength)
	_tween.parallel().tween_property(self, "wave", WAVE_END, WAVE_TIME).from(0.0)
	_tween.tween_interval(DURATION - FADE_IN - FADE_OUT)
	_tween.tween_callback(stop)


## Погасить импульс раньше времени (например, предмет уже выбран).
func stop(fade: float = FADE_OUT) -> void:
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "strength", 0.0, fade)
	_tween.tween_callback(finished.emit)


func _update_mark() -> void:
	for i in mini(_targets.size(), _marks.size()):
		var target := _targets[i]
		if target.size.x <= 0.0:
			continue
		var reach := (target.get_center() - _origin()).length()
		_marks[i].modulate.a = clampf((wave - reach + 120.0) / 120.0, 0.0, 1.0) * strength
		_marks[i].queue_redraw()


func _origin() -> Vector2:
	var value: Variant = _material.get_shader_parameter("origin")
	return value if value is Vector2 else Vector2.ZERO


## Уголки-скобки прицела вокруг предмета или подсказки (у мелкой подсказки скобки короче).
func _draw_mark(mark: Control) -> void:
	var r := Rect2(Vector2.ZERO, mark.size).grow(10.0)
	var arm := minf(36.0, mark.size.x * 0.3)
	for corner in [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]:
		var sx := 1.0 if corner.x == r.position.x else -1.0
		var sy := 1.0 if corner.y == r.position.y else -1.0
		mark.draw_line(corner, corner + Vector2(arm * sx, 0), MARK_COLOR, 5.0)
		mark.draw_line(corner, corner + Vector2(0, arm * sy), MARK_COLOR, 5.0)
