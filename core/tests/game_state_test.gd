extends TestCase


func test_battery_drops_per_chapter() -> void:
	var state := GameState.new()
	check_eq(state.battery.value, 4, "старт")
	state.complete_chapter()
	check_eq(state.battery.value, 3, "после главы 1")
	state.complete_chapter()
	state.complete_chapter()
	check_eq(state.battery.value, 1, "после главы 3")


func test_only_next_item_available() -> void:
	var state := GameState.new()
	check(state.is_item_available(0), "первый доступен")
	check(not state.is_item_available(1), "второй закрыт")
	state.complete_chapter()
	check(not state.is_item_available(0), "первый пройден")
	check(state.is_item_available(1), "второй открылся")


func test_lines_play_in_order_then_drain() -> void:
	var state := GameState.new()
	var drained := [false]
	state.lines_drained.connect(func() -> void: drained[0] = true)
	state.say("intro.1")
	state.say("intro.2")
	check_eq(state.current_line.value, Texts.get_text("intro.1"), "первая")
	state.finish_line()
	check_eq(state.current_line.value, Texts.get_text("intro.2"), "вторая")
	check(not drained[0], "ещё не всё")
	state.finish_line()
	check_eq(state.current_line.value, "", "очередь пуста")
	check(drained[0], "сигнал lines_drained")


func test_reset() -> void:
	var state := GameState.new()
	state.complete_chapter()
	state.face_on.value = true
	state.reset()
	check_eq(state.chapters_done.value, 0, "главы")
	check_eq(state.battery.value, 4, "батарейка")
	check(not state.face_on.value, "лицо выключено")
