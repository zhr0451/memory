class_name BatteryView extends Control
## Батарейка 128×64: 4 деления, заряд в половинках (0…8).
## Арт: ui_battery_N.png (N — полных делений 0…4) и, если есть, ui_battery_N_half.png — N делений и половинка.
## Без картинки половинки берётся ближайшая целая сверху.

const ASSET_DIR := "res://features/hero_hud/assets/"
const SEGMENTS := 4

## Заряд в половинках деления.
var level: int = SEGMENTS * 2:
	set(value):
		level = clampi(value, 0, SEGMENTS * 2)
		queue_redraw()

var _textures: Dictionary = {}


func _ready() -> void:
	custom_minimum_size = Vector2(128, 64)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var texture := _texture_for_level()
	if texture != null:
		draw_texture_rect(texture, Rect2(Vector2.ZERO, size), false)
		return
	var outline := Color("d5dae3")
	draw_rect(Rect2(2, 10, 108, 44), outline, false, 4.0)
	draw_rect(Rect2(110, 22, 12, 20), outline)
	var fill := Color("e0645a") if level <= 2 else Color("9fd08a")
	var full := level / 2
	for i in full:
		draw_rect(Rect2(10 + i * 25, 18, 21, 28), fill)
	if level % 2 == 1:
		draw_rect(Rect2(10 + full * 25, 18, 10, 28), fill)


func _texture_for_level() -> Texture2D:
	var full := level / 2
	if level % 2 == 1:
		var half := _texture("%d_half" % full)
		if half != null:
			return half
		return _texture(str(full + 1))
	return _texture(str(full))


func _texture(suffix: String) -> Texture2D:
	if not _textures.has(suffix):
		var path := "%sui_battery_%s.png" % [ASSET_DIR, suffix]
		_textures[suffix] = load(path) if ResourceLoader.exists(path) else null
	return _textures[suffix]
