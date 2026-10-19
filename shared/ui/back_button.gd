class_name BackButton extends GlyphButton
## Стрелка «назад» в углу мини-игры. Если есть ui_back.png, показывается она.

const ICON_PATH := "res://shared/ui/assets/ui_back.png"


func _ready() -> void:
	glyph = Glyph.BACK
	custom_minimum_size = Vector2(72, 72)
	size = custom_minimum_size
	position = Vector2(32, 32)
	focus_mode = Control.FOCUS_NONE
	if ResourceLoader.exists(ICON_PATH):
		icon = load(ICON_PATH) as Texture2D
		flat = true
		icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
