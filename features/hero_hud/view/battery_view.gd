class_name BatteryView extends Control
## Батарейка 128×64 на 5 состояний (4…0). Если есть ui_battery_N.png — берётся он.

const ASSET_DIR := "res://features/hero_hud/assets/"
const SEGMENTS := 4

var level: int = SEGMENTS:
	set(value):
		level = clampi(value, 0, SEGMENTS)
		queue_redraw()

var _textures: Dictionary = {}


func _ready() -> void:
	custom_minimum_size = Vector2(128, 64)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var texture := _texture_for(level)
	if texture != null:
		draw_texture_rect(texture, Rect2(Vector2.ZERO, size), false)
		return
	var outline := Color("d5dae3")
	draw_rect(Rect2(2, 10, 108, 44), outline, false, 4.0)
	draw_rect(Rect2(110, 22, 12, 20), outline)
	var fill := Color("e0645a") if level <= 1 else Color("9fd08a")
	for i in level:
		draw_rect(Rect2(10 + i * 25, 18, 21, 28), fill)


func _texture_for(value: int) -> Texture2D:
	if not _textures.has(value):
		var path := "%sui_battery_%d.png" % [ASSET_DIR, value]
		_textures[value] = load(path) if ResourceLoader.exists(path) else null
	return _textures[value]
