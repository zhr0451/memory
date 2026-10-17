extends TestCase


func test_blur_zero_at_target() -> void:
	var vm := MinigameProjectorViewModel.new()
	vm.set_angle(MinigameProjectorViewModel.TARGET_ANGLE)
	check_eq(vm.blur.value, 0.0, "в цели резко")
	vm.set_angle(MinigameProjectorViewModel.TARGET_ANGLE + 180.0)
	check_eq(vm.blur.value, MinigameProjectorViewModel.MAX_BLUR, "напротив — максимум")


func test_solves_after_hold() -> void:
	var vm := MinigameProjectorViewModel.new()
	var solved := [false]
	vm.solved.connect(func() -> void: solved[0] = true)
	vm.set_angle(MinigameProjectorViewModel.TARGET_ANGLE + 3.0)
	vm.tick(0.6)
	check(not solved[0], "рано")
	vm.tick(0.6)
	check(solved[0], "держали больше секунды")


func test_hold_resets_when_leaving() -> void:
	var vm := MinigameProjectorViewModel.new()
	var solved := [false]
	vm.solved.connect(func() -> void: solved[0] = true)
	vm.set_angle(MinigameProjectorViewModel.TARGET_ANGLE)
	vm.tick(0.8)
	vm.set_angle(0.0)
	vm.tick(0.1)
	vm.set_angle(MinigameProjectorViewModel.TARGET_ANGLE)
	vm.tick(0.8)
	check(not solved[0], "отсчёт сброшен")
