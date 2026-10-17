class_name IntroView extends Control
## Чёрный экран → писк → лицо включается → реплики → свалка проявляется.

var _vm: IntroViewModel


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var black := ColorRect.new()
	black.color = Color.BLACK
	add_child(black)
	black.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bind(IntroViewModel.new(Game.state))
	_run()


func bind(vm: IntroViewModel) -> void:
	_vm = vm


func _run() -> void:
	await get_tree().create_timer(1.2).timeout
	_vm.power_on()
	await get_tree().create_timer(1.0).timeout
	await _vm.speak()
	await get_tree().create_timer(0.4).timeout
	SceneManager.change_to(&"junkyard", {}, 1.0, 2.2)
