extends TestCase

func _set_value(vm: MinigameProjectorViewModel, knob: int, value: float) -> void:
	vm.set_angle(knob, MinigameProjectorViewModel.angle_for(value))


func _solve(vm: MinigameProjectorViewModel) -> void:
	for knob in [MinigameProjectorViewModel.Knob.LAMP, MinigameProjectorViewModel.Knob.FRAME, MinigameProjectorViewModel.Knob.ZOOM]:
		_set_value(vm, knob, MinigameProjectorViewModel.TARGETS[knob])
	_set_value(vm, MinigameProjectorViewModel.Knob.FOCUS, vm.focus_target())


func test_start_state_is_wrong() -> void:
	var vm := MinigameProjectorViewModel.new()
	check_eq(vm.correct_count(), 0, "в начале всё неверно")


func test_all_knobs_right_solves_on_submit() -> void:
	var vm := MinigameProjectorViewModel.new()
	var solved := [false]
	vm.solved.connect(func() -> void: solved[0] = true)
	_solve(vm)
	check(not solved[0], "само не решается, нужна кнопка")
	vm.submit()
	check(solved[0], "решено после «Готово»")
	check_eq(vm.blur, 0.0, "резко")


func test_partial_reports_count_and_does_not_solve() -> void:
	var vm := MinigameProjectorViewModel.new()
	var reported := [-1]
	var solved := [false]
	vm.submitted.connect(func(count: int, _total: int) -> void: reported[0] = count)
	vm.solved.connect(func() -> void: solved[0] = true)
	_set_value(vm, MinigameProjectorViewModel.Knob.LAMP, MinigameProjectorViewModel.TARGETS[MinigameProjectorViewModel.Knob.LAMP])
	_set_value(vm, MinigameProjectorViewModel.Knob.FRAME, MinigameProjectorViewModel.TARGETS[MinigameProjectorViewModel.Knob.FRAME])
	vm.submit()
	check_eq(reported[0], 2, "две ручки верны")
	check(not solved[0], "не решено")


func test_focus_target_follows_zoom() -> void:
	var vm := MinigameProjectorViewModel.new()
	_solve(vm)
	_set_value(vm, MinigameProjectorViewModel.Knob.ZOOM, 0.2)
	check(not vm.knob_correct(MinigameProjectorViewModel.Knob.FOCUS), "после смены масштаба фокус сбился")
	_set_value(vm, MinigameProjectorViewModel.Knob.FOCUS, vm.focus_target())
	check(vm.knob_correct(MinigameProjectorViewModel.Knob.FOCUS), "фокус подстроен под новый масштаб")


func test_glare_and_darkness_by_lamp() -> void:
	var vm := MinigameProjectorViewModel.new()
	_set_value(vm, MinigameProjectorViewModel.Knob.LAMP, 0.05)
	check(vm.darkness > 0.5 and vm.glare == 0.0, "тёмно")
	_set_value(vm, MinigameProjectorViewModel.Knob.LAMP, 0.95)
	check(vm.glare > 0.5 and vm.darkness == 0.0, "засвет")
