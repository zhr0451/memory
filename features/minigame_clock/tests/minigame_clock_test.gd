extends TestCase


func _set_correct(vm: MinigameClockViewModel) -> void:
	vm.set_hour(7)
	vm.set_minute(30)
	vm.set_pm(false)
	for i in 7:
		var want := (MinigameClockViewModel.WORKDAYS >> i) & 1 == 1
		if vm.is_day_on(i) != want:
			vm.toggle_day(i)


func test_target_is_derived_from_note() -> void:
	check_eq(MinigameClockViewModel.target_minutes(), 7 * 60 + 30, "07:30")


func test_correct_state_solves_on_submit() -> void:
	var vm := MinigameClockViewModel.new()
	var solved := [false]
	vm.solved.connect(func() -> void: solved[0] = true)
	_set_correct(vm)
	check(not solved[0], "нужна кнопка")
	vm.submit()
	check(solved[0], "решено")


func test_wrong_pieces_fail() -> void:
	var vm := MinigameClockViewModel.new()
	_set_correct(vm)
	vm.set_pm(true)
	check(not vm.is_correct(), "вечер вместо утра")
	vm.set_pm(false)
	vm.toggle_day(5)
	check(not vm.is_correct(), "включена суббота")
	vm.toggle_day(5)
	vm.set_minute(25)
	check(not vm.is_correct(), "не те минуты")


func test_wrong_submit_does_not_solve() -> void:
	var vm := MinigameClockViewModel.new()
	var result := [null]
	var solved := [false]
	vm.submitted.connect(func(ok: bool) -> void: result[0] = ok)
	vm.solved.connect(func() -> void: solved[0] = true)
	vm.submit()
	check_eq(result[0], false, "вердикт «неверно»")
	check(not solved[0], "не решено")


func test_knob_angles_snap() -> void:
	check_eq(MinigameClockViewModel.hour_from_angle(-90.0), 12, "вверх — 12")
	check_eq(MinigameClockViewModel.hour_from_angle(90.0), 6, "вниз — 6")
	check_eq(MinigameClockViewModel.minute_from_angle(90.0), 30, "вниз — 30 минут")
	check_eq(MinigameClockViewModel.minute_from_angle(0.0), 15, "вправо — 15 минут")
