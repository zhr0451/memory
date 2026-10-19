class_name ScanOverlay extends ColorRect
## Фильтр режима сканера поверх свалки (шейдер scan.gdshader) и рамка-прицел вокруг найденного предмета.
## Импульс: экран зеленеет, волна бежит от сканера, предмет проявляется; через DURATION всё гаснет.

signal finished

const SHADER := preload("res://features/junkyard/view/scan.gdshader")
const DURATION := 3.0
const FADE_IN := 0.35
const FADE_OUT := 0.5
const WAVE_TIME := 1.3
const WAVE_END := 2300.0
const MARK_COLOR := Color(0.55, 1.0, 0.7)

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
var _target := Rect2()
var _mark: Control
var _tween: Tween


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_material.shader = SHADER
	material = _material
	_mark = Control.new()
	_mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mark.draw.connect(_draw_mark)
	add_child(_mark)
	strength = 0.0


## origin — откуда идёт волна, target — прямоугольник предмета в координатах экрана (пустой — нечего показать).
func pulse(origin: Vector2, target: Rect2) -> void:
	_target = target
	_material.set_shader_parameter("origin", origin)
	_material.set_shader_parameter("canvas_size", size)
	_material.set_shader_parameter("target", Vector4(target.position.x, target.position.y, target.size.x, target.size.y))
	_mark.position = target.position
	_mark.size = target.size
	_mark.modulate.a = 0.0
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
	if _mark == null or _target.size.x <= 0.0:
		return
	var reach := (_target.get_center() - _origin()).length()
	_mark.modulate.a = clampf((wave - reach + 120.0) / 120.0, 0.0, 1.0) * strength
	_mark.queue_redraw()


func _origin() -> Vector2:
	var value: Variant = _material.get_shader_parameter("origin")
	return value if value is Vector2 else Vector2.ZERO


## Уголки-скобки прицела вокруг предмета.
func _draw_mark() -> void:
	var r := Rect2(Vector2.ZERO, _mark.size).grow(10.0)
	var arm := 36.0
	for corner in [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]:
		var sx := 1.0 if corner.x == r.position.x else -1.0
		var sy := 1.0 if corner.y == r.position.y else -1.0
		_mark.draw_line(corner, corner + Vector2(arm * sx, 0), MARK_COLOR, 5.0)
		_mark.draw_line(corner, corner + Vector2(0, arm * sy), MARK_COLOR, 5.0)
