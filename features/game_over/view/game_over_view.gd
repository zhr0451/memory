class_name GameOverView extends Control
## Экран проигрыша: тёмный фон, реплика, лицо гаснет, «Батарейка села» и кнопка «Попробовать ещё».

var _vm: GameOverViewModel
var _panel: Control


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var black := ColorRect.new()
	black.color = Color("0d0f14")
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(black)
	black.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_panel()
	bind(GameOverViewModel.new(Game.state))
	_run()


func bind(vm: GameOverViewModel) -> void:
	_vm = vm


func _build_panel() -> void:
	_panel = Control.new()
	_panel.modulate.a = 0.0
	_panel.visible = false
	add_child(_panel)
	_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var title := Label.new()
	title.text = Texts.get_text("game_over.title")
	title.position = Vector2(0, 360)
	title.size = Vector2(1920, 120)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 72)
	title.add_theme_color_override("font_color", Color("e0645a"))
	_panel.add_child(title)
	var retry := Button.new()
	retry.text = Texts.get_text("ui.retry")
	retry.position = Vector2(760, 540)
	retry.size = Vector2(400, 96)
	retry.focus_mode = Control.FOCUS_NONE
	retry.add_theme_font_size_override("font_size", 40)
	UiStyle.style_button(retry)
	retry.pressed.connect(_on_retry)
	_panel.add_child(retry)


func _run() -> void:
	await get_tree().create_timer(0.6).timeout
	await _vm.speak()
	_vm.power_off()
	await get_tree().create_timer(1.0).timeout
	_panel.visible = true
	create_tween().tween_property(_panel, "modulate:a", 1.0, 0.8)


func _on_retry() -> void:
	_vm.retry()
	Game.on_retry()
