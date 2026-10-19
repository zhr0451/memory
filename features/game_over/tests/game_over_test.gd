extends TestCase


func test_four_mistakes_kill_battery() -> void:
	var state := GameState.new()
	var dead := [0]
	state.battery_dead.connect(func() -> void: dead[0] += 1)
	for i in 3:
		state.mistake()
	check_eq(state.charge.value, 2, "три ошибки — осталось одно деление")
	check_eq(dead[0], 0, "ещё жив")
	state.mistake()
	check(state.is_dead(), "четвёртая ошибка — батарейка села")
	check_eq(dead[0], 1, "сигнал battery_dead один раз")
	state.mistake()
	check_eq(dead[0], 1, "после смерти ошибки не считаются")


func test_chapter_drains_half_and_never_kills() -> void:
	var state := GameState.new()
	state.complete_item(true)
	check_eq(state.charge.value, GameState.MAX_CHARGE - 1, "глава — минус половинка")
	state.charge.value = 1
	state.complete_item(true)
	check_eq(state.charge.value, 1, "за пройденную главу в ноль не садится")
	check(not state.is_dead(), "жив")


func test_no_mistakes_reach_finale_with_charge() -> void:
	var state := GameState.new()
	for i in Story.item_count():
		state.complete_item(Story.ends_chapter(i))
	check_eq(state.charge.value, GameState.MAX_CHARGE - Story.chapter_count(), "без ошибок к финалу 2 деления")


func test_retry_restores_chapter_start() -> void:
	var state := GameState.new()
	state.complete_item(false)
	state.complete_item(true)  # глава 1 закрыта
	state.emotion.value = Emotion.Kind.WORRY
	state.save_checkpoint()
	var start_charge: int = state.charge.value
	state.floppy_found.value = true
	state.complete_item(false)
	for i in 4:
		state.mistake()
	check(state.is_dead(), "проиграл")
	var vm := GameOverViewModel.new(state)
	vm.power_off()
	vm.retry()
	check_eq(state.items_done.value, 2, "предметы — как в начале главы")
	check_eq(state.chapters_done.value, 1, "главы")
	check_eq(state.charge.value, start_charge, "заряд — как в начале главы")
	check_eq(state.emotion.value, Emotion.Kind.WORRY, "эмоция начала главы")
	check(state.face_on.value, "лицо снова включено")
	check(state.floppy_found.value, "найденная дискета осталась")


func test_retry_in_first_chapter_starts_full() -> void:
	var state := GameState.new()
	state.reset()
	state.complete_item(false)
	for i in 4:
		state.mistake()
	state.restart_chapter()
	check_eq(state.items_done.value, 0, "с первого предмета")
	check_eq(state.charge.value, GameState.MAX_CHARGE, "полная батарейка")
