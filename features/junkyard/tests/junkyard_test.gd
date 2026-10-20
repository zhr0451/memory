extends TestCase


func test_find_note_sets_flag_once_and_speaks() -> void:
	var state := GameState.new()
	var vm := JunkyardViewModel.new(state)
	var found: Array = []
	vm.clue_found.connect(func(clue: JunkyardViewModel.Clue) -> void: found.append(clue))
	vm.find_clue(JunkyardViewModel.Clue.NOTE)
	vm.find_clue(JunkyardViewModel.Clue.NOTE)
	check(state.clock_note_found.value, "флаг выставлен")
	check(not state.floppy_found.value, "дискета не тронута")
	check_eq(found, [JunkyardViewModel.Clue.NOTE], "сигнал один раз")
	check_eq(state.current_line.value, Texts.get_text("junk.note.found"), "реплика героя")
	state.reset()
	check(not state.clock_note_found.value, "reset сбрасывает находку")


func test_find_floppy() -> void:
	var state := GameState.new()
	var vm := JunkyardViewModel.new(state)
	check(not vm.is_clue_found(JunkyardViewModel.Clue.FLOPPY), "ещё не найдена")
	vm.find_clue(JunkyardViewModel.Clue.FLOPPY)
	check(state.floppy_found.value, "флаг дискеты")
	check(vm.is_clue_found(JunkyardViewModel.Clue.FLOPPY), "найдена")
	check_eq(state.current_line.value, Texts.get_text("junk.floppy.found"), "реплика героя")


func test_item_states() -> void:
	var state := GameState.new()
	var vm := JunkyardViewModel.new(state)
	check_eq(vm.item_state(0), JunkyardViewModel.ItemState.AVAILABLE, "первый доступен")
	check_eq(vm.item_state(1), JunkyardViewModel.ItemState.LOCKED, "второй закрыт")
	check(not vm.select(1), "закрытый не выбирается")
	state.complete_item(false)
	check_eq(vm.item_state(0), JunkyardViewModel.ItemState.DONE, "первый пройден")
	check_eq(vm.item_state(1), JunkyardViewModel.ItemState.AVAILABLE, "второй открылся")



func test_find_fridge_drawing() -> void:
	var state := GameState.new()
	var vm := JunkyardViewModel.new(state)
	vm.find_clue(JunkyardViewModel.Clue.FRIDGE)
	check(state.phone_note_found.value, "рисунок для телефона найден")
	check(not state.clock_note_found.value, "записка к будильнику не тронута")
	check_eq(state.current_line.value, Texts.get_text("junk.fridge.found"), "реплика героя")


func test_scan_shows_available_item_and_costs_half() -> void:
	var state := GameState.new()
	var vm := JunkyardViewModel.new(state)
	state.complete_item(false)
	var shown: Array = []
	vm.scan_started.connect(func(index: int) -> void: shown.append(index))
	check(vm.scan(), "скан включился")
	check(vm.scanning.value, "идёт импульс")
	check_eq(shown, [1], "проявлен доступный предмет")
	check_eq(state.charge.value, GameState.MAX_CHARGE - GameState.SCAN_COST, "минус половинка")
	check(not vm.scan(), "во время импульса повторно не включается")
	check_eq(state.charge.value, GameState.MAX_CHARGE - GameState.SCAN_COST, "второй раз не списано")
	vm.end_scan()
	check(not vm.scanning.value, "импульс погас")
	check(vm.select(1), "предмет кликается и без скана")


func test_scan_first_line_only_once() -> void:
	var state := GameState.new()
	var vm := JunkyardViewModel.new(state)
	vm.scan()
	check_eq(state.current_line.value, Texts.get_text("scan.first"), "реплика при первом скане")
	state.finish_line()
	vm.end_scan()
	vm.scan()
	check_eq(state.current_line.value, "", "второй раз молчит")
	state.restart_chapter()
	check(state.scanner_used.value, "после проигрыша сканер помнится")
	state.reset()
	check(not state.scanner_used.value, "новая игра — снова реплика")


func test_scan_refused_on_last_half() -> void:
	var state := GameState.new()
	var vm := JunkyardViewModel.new(state)
	state.charge.value = GameState.SCAN_COST
	check(not vm.scan(), "на последней половинке не сканирует")
	check_eq(state.charge.value, GameState.SCAN_COST, "заряд не тронут")
	check(not vm.scanning.value, "импульса нет")
	check_eq(state.current_line.value, Texts.get_text("scan.low"), "герой объясняет")
	check(not state.is_dead(), "сканом не проиграть")


func test_scanner_reveals_clue_of_available_item() -> void:
	var state := GameState.new()
	var vm := JunkyardViewModel.new(state)
	check_eq(vm.clue_for(0), -1, "у проектора подсказки нет")
	check_eq(vm.clue_for(-1), -1, "доступных нет — нечего показать")
	state.complete_item(false)
	check_eq(vm.clue_for(1), JunkyardViewModel.Clue.FRIDGE, "у телефона — рисунок на холодильнике")
	vm.find_clue(JunkyardViewModel.Clue.FRIDGE)
	check_eq(vm.clue_for(1), -1, "найденную подсказку не показывает")
