extends TestCase


func test_solves_on_target_time() -> void:
	var vm := MinigameClockViewModel.new()
	var solved := [false]
	vm.solved.connect(func() -> void: solved[0] = true)
	vm.hours.value = 6
	vm.minutes.value = 30
	check(not solved[0], "прямое присвоение не проверяет")
	vm.change_hours(1)
	check(solved[0], "07:30")


func test_wraps_around() -> void:
	var vm := MinigameClockViewModel.new()
	vm.hours.value = 23
	vm.change_hours(1)
	check_eq(vm.hours.value, 0, "часы")
	vm.minutes.value = 55
	vm.change_minutes(1)
	check_eq(vm.minutes.value, 0, "минуты")
	check_eq(vm.time_text(), "00:00", "формат")
