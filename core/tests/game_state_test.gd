extends TestCase


func test_battery_drops_per_chapter_not_per_item() -> void:
	var state := GameState.new()
	check_eq(state.charge.value, 8, "старт: 4 деления = 8 половинок")
	state.complete_item(false)
	check_eq(state.charge.value, 8, "первый предмет главы — батарейка та же")
	check_eq(state.items_done.value, 1, "предмет засчитан")
	state.complete_item(true)
	check_eq(state.charge.value, 7, "после главы 1 — минус половинка")
	state.complete_item(true)
	state.complete_item(true)
	check_eq(state.charge.value, 5, "после главы 3")
	check_eq(state.chapters_done.value, 3, "главы")


func test_only_next_item_available() -> void:
	var state := GameState.new()
	check(state.is_item_available(0), "первый доступен")
	check(not state.is_item_available(1), "второй закрыт")
	state.complete_item(false)
	check(not state.is_item_available(0), "первый пройден")
	check(state.is_item_available(1), "второй открылся и внутри главы")


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
	state.complete_item(true)
	state.face_on.value = true
	state.floppy_found.value = true
	state.reset()
	check_eq(state.items_done.value, 0, "предметы")
	check_eq(state.chapters_done.value, 0, "главы")
	check_eq(state.charge.value, GameState.MAX_CHARGE, "батарейка")
	check(not state.face_on.value, "лицо выключено")
	check(not state.floppy_found.value, "дискета не найдена")


func test_story_chapters_are_ordered() -> void:
	var previous := 1
	for i in Story.item_count():
		var chapter := Story.item(i).chapter
		check(chapter == previous or chapter == previous + 1, "главы идут подряд: предмет %d" % i)
		previous = chapter
	check_eq(Story.item(0).chapter, 1, "начинаем с главы 1")
	check_eq(Story.chapter_count(), GameState.MAX_BATTERY, "глав столько же, сколько делений батарейки")
	check(Story.ends_chapter(Story.item_count() - 1), "последний предмет закрывает главу")


func test_chapter_end_items_have_reaction() -> void:
	for i in Story.item_count():
		if Story.ends_chapter(i):
			check(Story.item(i).after_line_key != "", "реплика после главы у предмета %d" % i)
