class_name MinigameProjectorView extends MinigameView
## Диафильм: четыре ручки по шагам (лампа, кадр, масштаб, фокус).
## Доступна одна ручка; подсказка под экраном говорит, что не так с картинкой.

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
var _hint: Label
var _step_label: Label
var _labels: Dictionary = {}


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
	_add_rect(Rect2(360, 600, 1000, 300), Color("2a2f3a"))
	for entry in KNOB_LAYOUT:
		var knob := Knob.new()
		knob.position = Vector2(entry[2], 630)
		add_child(knob)
		_knobs[entry[0]] = knob
		_labels[entry[0]] = _add_label(Texts.get_text(entry[1]), Rect2(entry[2] - 20, 800, 200, 50), 32, Color("c5ccd8"))
	_step_label = _add_label("", Rect2(560, 535, 800, 40), 28, Color("8e99a8"))
	_hint = _add_label("", Rect2(1400, 630, 440, 230), 36, Color("e6c86a"))
	bind(MinigameProjectorViewModel.new())


func bind(vm: MinigameProjectorViewModel) -> void:
	_vm = vm
	for knob_id in _knobs:
		var knob: Knob = _knobs[knob_id]
		knob.angle = MinigameProjectorViewModel.angle_for(vm.values[knob_id])
		knob.angle_changed.connect(func(degrees: float) -> void: vm.set_angle(knob_id, degrees))
	vm.visuals_changed.connect(_apply_visuals)
	vm.step_changed.connect(func(_step: int) -> void: _update_steps())
	vm.solved.connect(_on_solved)
	_apply_visuals()
	_update_steps()


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
	if _hint != null:
		_hint.text = Texts.get_text(_vm.hint_key())


func _update_steps() -> void:
	var step: int = _vm.step.value
	_step_label.text = Texts.get_text("projector.step") % [mini(step + 1, MinigameProjectorViewModel.Knob.size()), MinigameProjectorViewModel.Knob.size()]
	_hint.text = Texts.get_text(_vm.hint_key())
	for knob_id in _knobs:
		var knob: Knob = _knobs[knob_id]
		knob.enabled = _vm.is_active(knob_id)
		var label: Label = _labels[knob_id]
		label.add_theme_color_override("font_color", Color("e6c86a") if _vm.is_active(knob_id) else (Color("9fd08a") if _vm.is_locked(knob_id) else Color("6b7384")))


func _on_solved() -> void:
	create_tween().tween_property(_picture, "modulate", Color(1.2, 1.15, 1.0), 0.4)
	_finish()
