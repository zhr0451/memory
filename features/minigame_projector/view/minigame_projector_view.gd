class_name MinigameProjectorView extends MinigameView
## Диафильм: крутить ручку проектора, пока картинка не станет чёткой.

const PICTURE_RECT := Rect2(560, 110, 800, 450)
const SHADER := preload("res://features/minigame_projector/assets/blur.gdshader")

var _vm: MinigameProjectorViewModel
var _material := ShaderMaterial.new()
var _knob: Knob
var _picture: Control


func _build() -> void:
	_add_rect(Rect2(0, 0, 1920, 1080), Color("14171d"))
	_picture = ProjectorPicture.new()
	_picture.position = PICTURE_RECT.position
	_picture.size = PICTURE_RECT.size
	add_child(_picture)
	var overlay := _add_rect(PICTURE_RECT, Color.WHITE)
	_material.shader = SHADER
	overlay.material = _material
	_add_rect(Rect2(620, 660, 680, 260), Color("3d4452"))
	_add_rect(Rect2(660, 700, 220, 150), Color("2a2f3a"))
	_add_label(Texts.get_text("item.projector"), Rect2(620, 860, 400, 50), 28, Color("aab2c2"))
	_knob = Knob.new()
	_knob.position = Vector2(1060, 700)
	add_child(_knob)
	bind(MinigameProjectorViewModel.new())


func bind(vm: MinigameProjectorViewModel) -> void:
	_vm = vm
	_knob.angle_changed.connect(vm.set_angle)
	vm.angle.changed.connect(func(a: float) -> void: _knob.angle = a)
	vm.blur.changed.connect(_on_blur_changed)
	vm.solved.connect(_on_solved)
	_on_blur_changed(vm.blur.value)


func _process(delta: float) -> void:
	if _vm != null:
		_vm.tick(delta)


func _on_blur_changed(value: float) -> void:
	_material.set_shader_parameter("blur", value)


func _on_solved() -> void:
	create_tween().tween_property(_picture, "modulate", Color(1.25, 1.2, 1.0), 0.4)
	_finish()
