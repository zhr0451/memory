extends TestCase

const Line := MinigamePhoneViewModel.Line


func _dial_all(vm: MinigamePhoneViewModel, number: String) -> void:
	for ch in number:
		vm.dial(int(ch))


func test_picture_riddle_spells_the_number() -> void:
	# Радуга — 7 цветов, кошка — 4 лапы, велосипед — 2 колеса, ладошка — 5 пальцев, бублик — 0, торт с одной свечкой — 1.
	var counts := {
		PictureNoteView.Picture.RAINBOW: 7, PictureNoteView.Picture.CAT: 4, PictureNoteView.Picture.BIKE: 2,
		PictureNoteView.Picture.HAND: 5, PictureNoteView.Picture.BAGEL: 0, PictureNoteView.Picture.CANDLE: 1,
	}
	var spelled := ""
	for picture in PictureNoteView.ORDER:
		spelled += str(counts[picture])
	check_eq(spelled, MinigamePhoneViewModel.NUMBER, "рисунок = номер")


func test_correct_number_rings() -> void:
	var vm := MinigamePhoneViewModel.new()
	var solved := [0]
	vm.solved.connect(func() -> void: solved[0] += 1)
	vm.toggle_receiver()
	check_eq(vm.line.value, Line.TONE, "гудок")
	_dial_all(vm, "74250")
	check_eq(vm.line.value, Line.DIALING, "набор идёт")
	check_eq(solved[0], 0, "вердикт только после шестой цифры")
	vm.dial(1)
	check_eq(vm.line.value, Line.RINGING, "длинные гудки")
	check_eq(solved[0], 1, "решено")
	vm.toggle_receiver()
	check_eq(vm.line.value, Line.RINGING, "после решения трубку не положить")


func test_wrong_number_is_busy_and_hook_resets() -> void:
	var vm := MinigamePhoneViewModel.new()
	vm.toggle_receiver()
	_dial_all(vm, "123456")
	check_eq(vm.line.value, Line.BUSY, "короткие гудки")
	vm.dial(7)
	check_eq(vm.dialed.value, "123456", "в занятую линию не набрать")
	vm.press_hook()
	check_eq(vm.line.value, Line.TONE, "рычаг — снова гудок")
	check_eq(vm.dialed.value, "", "набор сброшен")
	_dial_all(vm, MinigamePhoneViewModel.NUMBER)
	check(vm.is_solved(), "со второй попытки")


func test_no_tone_without_receiver() -> void:
	var state := GameState.new()
	state.phone_note_found.value = true
	var vm := MinigamePhoneViewModel.new(state)
	var pulses: Array = []
	vm.dialed_digit.connect(func(_d: int, p: int) -> void: pulses.append(p))
	vm.dial(3)
	vm.dial(0)
	check_eq(vm.dialed.value, "", "трубка лежит — цифры не набираются")
	check_eq(pulses, [3, 10], "щелчки всё равно слышны, ноль — десять")
	check_eq(state.current_line.value, Texts.get_text("phone.no_tone"), "герой подсказывает снять трубку")
	state.finish_line()
	check_eq(state.current_line.value, "", "подсказка один раз")


func test_hanging_up_clears() -> void:
	var vm := MinigamePhoneViewModel.new()
	vm.toggle_receiver()
	_dial_all(vm, "74")
	vm.toggle_receiver()
	check_eq(vm.line.value, Line.HUNG_UP, "положили")
	check_eq(vm.dialed.value, "", "набор сброшен")


func test_dial_geometry() -> void:
	check(MinigamePhoneViewModel.pull_needed(1) < MinigamePhoneViewModel.pull_needed(2), "1 ближе к упору, чем 2")
	check(MinigamePhoneViewModel.pull_needed(0) > MinigamePhoneViewModel.pull_needed(9), "0 дальше всех")
	for digit in 10:
		var landed := fposmod(MinigamePhoneViewModel.hole_angle(digit) + MinigamePhoneViewModel.pull_needed(digit), 360.0)
		check(absf(landed - MinigamePhoneViewModel.STOP_ANGLE) < 0.01, "цифра %d доходит до упора" % digit)
	check(MinigamePhoneViewModel.reached_stop(5, MinigamePhoneViewModel.pull_needed(5)), "до упора — засчитано")
	check(not MinigamePhoneViewModel.reached_stop(5, MinigamePhoneViewModel.pull_needed(5) - 30.0), "не дотянул — не засчитано")


func test_confused_without_note() -> void:
	var state := GameState.new()
	var vm := MinigamePhoneViewModel.new(state)
	vm.activate()
	check_eq(state.current_line.value, Texts.get_text("phone.confused"), "герой не знает номера")
