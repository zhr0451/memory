extends SceneTree
## Дымовой прогон всей игры без ввода: godot --headless --path . -s tests/smoke_playthrough.gd
## Проходит интро → 3 главы → последний день → финал, дёргая ViewModel напрямую.


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
	for chapter in 3:
		var junkyard := _scene()
		assert(junkyard.get("_vm").select(chapter))
		await _wait_for(Story.chapter(chapter).minigame_scene)
		var minigame := _scene()
		var vm: Object = minigame.get("_vm")
		match chapter:
			0:
				for knob in [MinigameProjectorViewModel.Knob.LAMP, MinigameProjectorViewModel.Knob.FRAME, MinigameProjectorViewModel.Knob.ZOOM]:
					vm.set_angle(knob, MinigameProjectorViewModel.angle_for(MinigameProjectorViewModel.TARGETS[knob]))
				vm.set_angle(MinigameProjectorViewModel.Knob.FOCUS, MinigameProjectorViewModel.angle_for(vm.focus_target()))
				vm.submit()
			1:
				vm.set_hour(7)
				vm.set_minute(30)
				vm.set_pm(false)
				for i in 7:
					if vm.is_day_on(i) != ((MinigameClockViewModel.WORKDAYS >> i) & 1 == 1):
						vm.toggle_day(i)
				vm.submit()
			2:
				var target := MinigameRadioViewModel.stations()[MinigameRadioViewModel.TARGET_STATION]
				vm.set_angle(MinigameRadioViewModel.angle_for(target.frequency))
				vm.insert_cassette(MinigameRadioViewModel.TARGET_CASSETTE)
				vm.submit()
		await _wait_for(&"memory")
		var memory := _scene()
		var memory_vm: MemorySlideshowViewModel = memory.get("_vm")
		for f in memory_vm.frames.size():
			memory_vm.next()
		print("chapter %d ok, battery %d" % [chapter + 1, game.state.battery.value])
		if chapter < 2:
			await _wait_for(&"junkyard")
	await _wait_for(&"memory")
	var last := _scene().get("_vm") as MemorySlideshowViewModel
	for f in last.frames.size():
		last.next()
	await _wait_for(&"finale")
	print("finale reached")
	while not _scene().get("_can_restart"):
		await process_frame
	print("SMOKE OK battery=%d" % game.state.battery.value)
	quit(0)
