extends SceneTree
## Дымовой прогон всей игры без ввода: godot --headless --path . -s tests/smoke_playthrough.gd
## Проходит интро → проигрыш и «ещё раз» → все предметы → последний день → финал, дёргая ViewModel напрямую.


func _initialize() -> void:
	_run()


func _scene() -> Node:
	return root.get_node("SceneManager")._current


func _wait_for(id: StringName) -> void:
	while true:
		var changed: StringName = await root.get_node("SceneManager").scene_changed
		if changed == id:
			return


func _run() -> void:
	var timeout := create_timer(150.0)
	timeout.timeout.connect(func() -> void:
		print("SMOKE TIMEOUT")
		quit(1))
	var main := (load("res://core/main/main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	while _scene() == null or _scene().name != &"LanguageSelect":
		await process_frame
	var language_view := _scene()
	language_view.get("_vm").choose("en")
	await _wait_for(&"junkyard")
	print("intro -> junkyard ok")
	var game: Node = root.get_node("Game")
	for i in 4:
		game.state.mistake()
	await _wait_for(&"game_over")
	while not (_scene().get("_panel") as Control).visible:
		await process_frame
	_scene().call("_on_retry")
	await _wait_for(&"junkyard")
	assert(game.state.charge.value == GameState.MAX_CHARGE and game.state.face_on.value)
	print("game over -> retry -> junkyard ok")
	game.state.floppy_found.value = true
	game.state.phone_note_found.value = true
	var count := Story.item_count()
	for index in count:
		var junkyard := _scene()
		assert(junkyard.get("_vm").select(index))
		var item := Story.item(index)
		await _wait_for(item.minigame_scene)
		var minigame := _scene()
		var vm: Object = minigame.get("_vm")
		match item.id:
			&"projector":
				for knob in MinigameProjectorViewModel.Knob.values():
					minigame.get("_knobs")[knob].angle_changed.emit(MinigameProjectorViewModel.angle_for(MinigameProjectorViewModel.TARGETS[knob]))
			&"phone":
				vm.toggle_receiver()
				for ch in MinigamePhoneViewModel.NUMBER:
					vm.dial(int(ch))
				assert(vm.is_solved())
			&"clock":
				vm.set_hour(7)
				vm.set_minute(30)
				vm.set_pm(false)
				for i in 7:
					if vm.is_day_on(i) != ((MinigameClockViewModel.WORKDAYS >> i) & 1 == 1):
						vm.toggle_day(i)
				vm.submit()
			&"radio":
				var target := MinigameRadioViewModel.stations()[MinigameRadioViewModel.TARGET_STATION]
				vm.set_angle(MinigameRadioViewModel.angle_for(target.frequency))
				vm.insert_cassette(MinigameRadioViewModel.TARGET_CASSETTE)
				vm.submit()
			&"computer":
				vm.toggle_monitor()
				vm.toggle_pc()
				vm.insert_floppy()
				for ch in Texts.get_text("computer.password"):
					var key := _find_key(vm, ch)
					vm.press_key(key.x, key.y)
				vm.enter()
				assert(vm.is_solved())
				minigame.call("_on_shutdown")
			_:
				push_error("smoke: нет решения для " + String(item.id))
				quit(1)
				return
		if not Story.frames_for(index).is_empty():
			await _wait_for(&"memory")
			var memory_vm: MemorySlideshowViewModel = _scene().get("_vm")
			for f in memory_vm.frames.size():
				memory_vm.next()
		print("item %s (chapter %d) ok, charge %d" % [item.id, item.chapter, game.state.charge.value])
		if index + 1 < count:
			await _wait_for(&"junkyard")
	await _wait_for(&"memory")
	var last := _scene().get("_vm") as MemorySlideshowViewModel
	for f in last.frames.size():
		last.next()
	await _wait_for(&"finale")
	print("finale reached")
	while not _scene().get("_can_restart"):
		await process_frame
	print("SMOKE OK charge=%d" % game.state.charge.value)
	quit(0)


func _find_key(vm: Object, ch: String) -> Vector2i:
	for row in MinigameComputerViewModel.ROWS.size():
		for column in (MinigameComputerViewModel.ROWS[row] as Array).size():
			if vm.key_char(row, column) == ch:
				return Vector2i(row, column)
	return Vector2i(-1, -1)
