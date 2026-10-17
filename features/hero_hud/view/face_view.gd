class_name FaceView extends Control
## Лицо героя 256×256. Пока нет арта, рисуется кодом; если есть hero_face_<эмоция>.png — берётся он.
## «Дыхание» (±2%) и дрожь на страх — кодом.

const ASSET_DIR := "res://features/hero_hud/assets/"
const BODY := Color("8e99a8")
const SCREEN_ON := Color("c8d3b0")
const SCREEN_OFF := Color("171a16")
const INK := Color("2b3320")
const BREATH := 0.02
const SHAKE := 3.0

var base_position: Vector2 = Vector2.ZERO
var emotion: Emotion.Kind = Emotion.Kind.OFF:
	set(value):
		emotion = value
		queue_redraw()

var _body_style := StyleBoxFlat.new()
var _textures: Dictionary = {}
var _time: float = 0.0


func _ready() -> void:
	custom_minimum_size = Vector2(256, 256)
	size = custom_minimum_size
	pivot_offset = size * 0.5
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_body_style.bg_color = BODY
	_body_style.set_corner_radius_all(40)


func _process(delta: float) -> void:
	_time += delta
	scale = Vector2.ONE * (1.0 + BREATH * sin(_time * 2.0))
	position = base_position
	if emotion == Emotion.Kind.FEAR:
		position += Vector2(randf_range(-SHAKE, SHAKE), randf_range(-SHAKE, SHAKE))


func _draw() -> void:
	var texture := _texture_for(emotion)
	if texture != null:
		draw_texture_rect(texture, Rect2(Vector2.ZERO, size), false)
		return
	draw_style_box(_body_style, Rect2(Vector2.ZERO, size))
	draw_rect(Rect2(24, 24, 208, 208), SCREEN_OFF if emotion == Emotion.Kind.OFF else SCREEN_ON)
	_draw_features()


func _texture_for(kind: Emotion.Kind) -> Texture2D:
	if not _textures.has(kind):
		var path := "%shero_face_%s.png" % [ASSET_DIR, Emotion.key(kind)]
		_textures[kind] = load(path) if ResourceLoader.exists(path) else null
	return _textures[kind]


func _draw_features() -> void:
	var left := Vector2(88, 112)
	var right := Vector2(168, 112)
	var mouth := Vector2(128, 172)
	match emotion:
		Emotion.Kind.JOY:
			_arc(left, 20, 180, 360)
			_arc(right, 20, 180, 360)
			_arc(mouth + Vector2(0, -14), 38, 20, 160)
		Emotion.Kind.MEMORY:
			_arc(left, 18, 0, 180)
			_arc(right, 18, 0, 180)
			_arc(mouth + Vector2(0, -8), 26, 30, 150)
			for i in 3:
				draw_circle(Vector2(196 + i * 10, 70 - i * 8), 3.0, INK)
		Emotion.Kind.WORRY:
			draw_circle(left + Vector2(0, 6), 11.0, INK)
			draw_circle(right + Vector2(0, 6), 11.0, INK)
			draw_line(Vector2(62, 92), Vector2(106, 72), INK, 5.0, true)
			draw_line(Vector2(150, 72), Vector2(194, 92), INK, 5.0, true)
			_arc(mouth + Vector2(0, 26), 30, 215, 325)
		Emotion.Kind.FEAR:
			draw_arc(left, 22, 0, TAU, 24, INK, 4.0, true)
			draw_arc(right, 22, 0, TAU, 24, INK, 4.0, true)
			draw_circle(left, 5.0, INK)
			draw_circle(right, 5.0, INK)
			draw_arc(mouth + Vector2(0, 6), 14, 0, TAU, 20, INK, 4.0, true)
		Emotion.Kind.DOUBT:
			draw_circle(left + Vector2(8, 0), 11.0, INK)
			draw_circle(right + Vector2(8, 0), 11.0, INK)
			draw_line(Vector2(66, 80), Vector2(110, 76), INK, 5.0, true)
			draw_line(Vector2(150, 84), Vector2(194, 88), INK, 5.0, true)
			draw_line(Vector2(98, 178), Vector2(158, 168), INK, 5.0, true)
		Emotion.Kind.SAD:
			draw_circle(left, 11.0, INK)
			draw_circle(right, 11.0, INK)
			draw_circle(left + Vector2(-2, 36), 6.0, INK)
			_arc(mouth + Vector2(0, 30), 34, 210, 330)


func _arc(center: Vector2, radius: float, from_deg: float, to_deg: float) -> void:
	draw_arc(center, radius, deg_to_rad(from_deg), deg_to_rad(to_deg), 24, INK, 5.0, true)
