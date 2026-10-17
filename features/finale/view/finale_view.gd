class_name FinaleView extends Control
## Пустая комната → последняя реплика → батарейка 0 → экран гаснет → титры.
## Фон — final_room.png, если он есть; иначе заглушка.

const ROOM_PATH := "res://features/finale/assets/final_room.png"

var _vm: FinaleViewModel
var _blackout: ColorRect
var _credits: Control
var _can_restart: bool = false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_room()
	_build_credits()
	for child in get_children():
		(child as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	bind(FinaleViewModel.new(Game.state))
	_run()


func bind(vm: FinaleViewModel) -> void:
	_vm = vm


func _input(event: InputEvent) -> void:
	if _can_restart and AdvanceInput.is_advance(event):
		Game.start_game()


func _build_room() -> void:
	if ResourceLoader.exists(ROOM_PATH):
		var room := TextureRect.new()
		room.texture = load(ROOM_PATH) as Texture2D
		add_child(room)
		room.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	else:
		var wall := ColorRect.new()
		wall.color = Color("4a3d30")
		add_child(wall)
		wall.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var floor_rect := ColorRect.new()
		floor_rect.color = Color("2e2620")
		floor_rect.position = Vector2(0, 760)
		floor_rect.size = Vector2(1920, 320)
		add_child(floor_rect)
		var bag := ColorRect.new()
		bag.color = Color("1a1714")
		bag.position = Vector2(1200, 600)
		bag.size = Vector2(300, 300)
		add_child(bag)
	_blackout = ColorRect.new()
	_blackout.color = Color.BLACK
	_blackout.modulate.a = 0.0
	_blackout.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_blackout)
	_blackout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _build_credits() -> void:
	_credits = Control.new()
	_credits.modulate.a = 0.0
	_credits.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_credits)
	_credits.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for entry in [["credits.title", 400, 84], ["credits.thanks", 540, 36], ["ui.restart", 940, 24]]:
		var label := Label.new()
		label.text = Texts.get_text(entry[0])
		label.position = Vector2(0, entry[1])
		label.size = Vector2(1920, 100)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", entry[2])
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_credits.add_child(label)


func _run() -> void:
	_vm.sad()
	await get_tree().create_timer(1.5).timeout
	await _vm.speak()
	await get_tree().create_timer(1.0).timeout
	_vm.power_off()
	await get_tree().create_timer(1.2).timeout
	var tween := create_tween()
	tween.tween_property(_blackout, "modulate:a", 1.0, 2.5)
	await tween.finished
	await get_tree().create_timer(1.0).timeout
	tween = create_tween()
	tween.tween_property(_credits, "modulate:a", 1.0, 2.0)
	await tween.finished
	_can_restart = true
