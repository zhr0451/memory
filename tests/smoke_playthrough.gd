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
				vm.set_angle(MinigameProjectorViewModel.TARGET_ANGLE)
			1:
				vm.hours.value = 6
				vm.minutes.value = 30
				vm.change_hours(1)
			2:
				for i in 3:
					vm.set_mode(MinigameTapeViewModel.Mode.STOP)
					vm.position.value = MinigameTapeViewModel.FRAGMENTS[i].x
					vm.set_mode(MinigameTapeViewModel.Mode.PLAY)
					for t in 400:
						vm.tick(0.01)
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
