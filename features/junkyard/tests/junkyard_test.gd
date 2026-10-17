extends TestCase


func test_find_note_sets_flag_once_and_speaks() -> void:
	var state := GameState.new()
	var vm := JunkyardViewModel.new(state)
	var found := [0]
	vm.note_found.connect(func() -> void: found[0] += 1)
	vm.find_note()
	vm.find_note()
	check(state.clock_note_found.value, "флаг выставлен")
	check_eq(found[0], 1, "сигнал один раз")
	check_eq(state.current_line.value, Texts.get_text("junk.note.found"), "реплика героя")
	state.reset()
	check(not state.clock_note_found.value, "reset сбрасывает находку")


func test_item_states() -> void:
	var state := GameState.new()
	var vm := JunkyardViewModel.new(state)
	check_eq(vm.item_state(0), JunkyardViewModel.ItemState.AVAILABLE, "первый доступен")
	check_eq(vm.item_state(1), JunkyardViewModel.ItemState.LOCKED, "второй закрыт")
	check(not vm.select(1), "закрытый не выбирается")
	state.complete_chapter()
	check_eq(vm.item_state(0), JunkyardViewModel.ItemState.DONE, "первый пройден")
