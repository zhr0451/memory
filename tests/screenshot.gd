extends SceneTree
## Снимок экрана игры в PNG (нужен дисплей, не headless):
## godot --path . -s tests/screenshot.gd -- <scene_id> <out.png> [item] [note] [floppy] [fridge] [scan]
## scan — на свалке включить сканер и снять экран, когда волна дойдёт до предмета.


func _initialize() -> void:
	_run()


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	# Игра стартует на весь экран, а снимки делаем в окне 1280×720.
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1280, 720))
	var scene_id := StringName(args[0])
	var out_path := args[1]
	var item := int(args[2]) if args.size() > 2 else 0
	var note_found := args.has("note")
	var floppy_found := args.has("floppy")
	var fridge_found := args.has("fridge")
	var main := (load("res://core/main/main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	await create_timer(0.5).timeout
	var game: Node = root.get_node("Game")
	game.state.hud_visible.value = true
	game.state.face_on.value = true
	game.state.emotion.value = 0
	game.state.clock_note_found.value = note_found
	game.state.floppy_found.value = floppy_found
	game.state.phone_note_found.value = fridge_found
	root.get_node("SceneManager").change_to(scene_id, {"item": item}, 0.0, 0.0)
	await create_timer(1.5).timeout
	if args.has("scan"):
		root.get_node("SceneManager")._current.call("start_scan")
		await create_timer(1.5).timeout
	await process_frame
	root.get_viewport().get_texture().get_image().save_png(out_path)
	print("saved ", out_path)
	quit(0)
