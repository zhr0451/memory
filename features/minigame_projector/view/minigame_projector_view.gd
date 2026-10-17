class_name MinigameProjectorView extends MinigameView
## Диафильм: четыре ручки (лампа, кадр, масштаб, фокус) и кнопка «Готово».
## Слева — образец правильного кадра; «Готово» показывает, сколько ручек стоит верно.

const SCREEN_RECT := Rect2(560, 70, 800, 450)
const SHADER := preload("res://features/minigame_projector/assets/blur.gdshader")
const KNOB_LAYOUT: Array = [
	[MinigameProjectorViewModel.Knob.LAMP, "projector.lamp", 420.0],
	[MinigameProjectorViewModel.Knob.FRAME, "projector.frame", 650.0],
	[MinigameProjectorViewModel.Knob.ZOOM, "projector.zoom", 880.0],
	[MinigameProjectorViewModel.Knob.FOCUS, "projector.focus", 1110.0],
]

var _vm: MinigameProjectorViewModel
var _material := ShaderMaterial.new()
var _knobs: Dictionary = {}
var _picture: ProjectorPicture
var _dark: ColorRect
var _glare: ColorRect
var _result: Label


func _build() -> void:
	_add_rect(Rect2(0, 0, 1920, 1080), Color("14171d"))
	_add_rect(SCREEN_RECT.grow(14), Color("0b0c10"))
	var screen := Control.new()
	screen.position = SCREEN_RECT.position
	screen.size = SCREEN_RECT.size
	screen.clip_contents = true
	screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(screen)
	var black := ColorRect.new()
	black.color = Color.BLACK
	black.size = SCREEN_RECT.size
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen.add_child(black)
	_picture = ProjectorPicture.new()
	_picture.size = SCREEN_RECT.size
	_picture.pivot_offset = SCREEN_RECT.size * 0.5
	screen.add_child(_picture)
	_dark = _add_overlay(Color(0, 0, 0, 0))
	_glare = _add_overlay(Color(1, 1, 1, 0))
	var blur_overlay := _add_overlay(Color.WHITE)
	_material.shader = SHADER
	blur_overlay.material = _material
	_build_sample()
	_add_rect(Rect2(360, 600, 1000, 300), Color("2a2f3a"))
	for entry in KNOB_LAYOUT:
		var knob := Knob.new()
		knob.position = Vector2(entry[2], 630)
		add_child(knob)
		_knobs[entry[0]] = knob
		_add_label(Texts.get_text(entry[1]), Rect2(entry[2] - 20, 800, 200, 50), 32, Color("c5ccd8"))
	_result = _add_label("", Rect2(1400, 590, 440, 90), 40)
	var done := _add_button(Texts.get_text("ui.done"), Rect2(1420, 710, 400, 120), 48)
	bind(MinigameProjectorViewModel.new())
	done.pressed.connect(_vm.submit)


func bind(vm: MinigameProjectorViewModel) -> void:
	_vm = vm
	for knob_id in _knobs:
		var knob: Knob = _knobs[knob_id]
		knob.angle = MinigameProjectorViewModel.angle_for(vm.values[knob_id])
		knob.angle_changed.connect(vm.set_angle.bind(knob_id))
	vm.visuals_changed.connect(_apply_visuals)
	vm.submitted.connect(_on_submitted)
	vm.solved.connect(_on_solved)
	_apply_visuals()


func _build_sample() -> void:
	var sample_rect := Rect2(150, 110, 320, 180)
	_add_rect(sample_rect.grow(8), Color("0b0c10"))
	var sample := ProjectorPicture.new()
	sample.position = sample_rect.position
	sample.size = sample_rect.size
	add_child(sample)
	_add_label(Texts.get_text("projector.sample"), Rect2(150, 300, 320, 50), 32, Color("c5ccd8"))


func _add_overlay(color: Color) -> ColorRect:
	var overlay := _add_rect(SCREEN_RECT, color)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return overlay


func _apply_visuals() -> void:
	_picture.position = Vector2(0, _vm.shift)
	_picture.scale = Vector2.ONE * _vm.picture_scale
	_dark.color.a = _vm.darkness
	_glare.color.a = _vm.glare
	_material.set_shader_parameter("blur", _vm.blur)


func _on_submitted(correct: int, total: int) -> void:
	_result.text = Texts.get_text("projector.result") % [correct, total]
	_result.add_theme_color_override("font_color", Color("9fd08a") if correct == total else Color("e0a060"))


func _on_solved() -> void:
	create_tween().tween_property(_picture, "modulate", Color(1.2, 1.15, 1.0), 0.4)
	_finish()
