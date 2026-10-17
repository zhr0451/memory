extends TestCase

func _set_value(vm: MinigameProjectorViewModel, knob: int, value: float) -> void:
	vm.set_angle(knob, MinigameProjectorViewModel.angle_for(value))


func test_starts_with_all_defects() -> void:
	var vm := MinigameProjectorViewModel.new()
	check_eq(vm.step.value, 0, "первый шаг — лампа")
	check(vm.darkness > 0.0, "картинка тёмная")
	check(vm.shift != 0.0 and vm.picture_scale != 1.0 and vm.blur > 0.0, "остальные дефекты тоже видны")


func test_inactive_knob_is_ignored() -> void:
	var vm := MinigameProjectorViewModel.new()
	_set_value(vm, MinigameProjectorViewModel.Knob.ZOOM, MinigameProjectorViewModel.TARGETS[MinigameProjectorViewModel.Knob.ZOOM])
	check_eq(vm.step.value, 0, "шаг не сдвинулся")


func test_correct_knob_locks_and_advances() -> void:
	var vm := MinigameProjectorViewModel.new()
	_set_value(vm, MinigameProjectorViewModel.Knob.LAMP, MinigameProjectorViewModel.TARGETS[MinigameProjectorViewModel.Knob.LAMP])
	check_eq(vm.step.value, 1, "перешли к кадру")
	check(vm.is_locked(MinigameProjectorViewModel.Knob.LAMP), "лампа зафиксирована")
	check_eq(vm.darkness, 0.0, "светло")
	check(vm.shift != 0.0 and vm.blur > 0.0, "остальные дефекты на месте")


func test_all_steps_solve() -> void:
	var vm := MinigameProjectorViewModel.new()
	var solved := [false]
	vm.solved.connect(func() -> void: solved[0] = true)
	for knob in MinigameProjectorViewModel.Knob.values():
		check(not solved[0], "ещё не решено")
		_set_value(vm, knob, MinigameProjectorViewModel.TARGETS[knob])
	check(solved[0], "решено после четвёртого шага")
	check(vm.blur == 0.0 and vm.shift == 0.0 and vm.darkness == 0.0 and vm.picture_scale == 1.0, "итоговая картинка чистая")


func test_hint_follows_picture() -> void:
	var vm := MinigameProjectorViewModel.new()
	check_eq(vm.hint_key(), "projector.hint.lamp_dark", "тёмно")
	_set_value(vm, MinigameProjectorViewModel.Knob.LAMP, 0.9)
	check_eq(vm.hint_key(), "projector.hint.lamp_bright", "засвет")
