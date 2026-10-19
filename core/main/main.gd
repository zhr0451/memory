extends Node
## Точка входа: подключает HUD героя и запускает игру.

const HERO_HUD := preload("res://features/hero_hud/hero_hud.tscn")


func _ready() -> void:
	var hud := HERO_HUD.instantiate() as HeroHudView
	add_child(hud)
	hud.bind(HeroHudViewModel.new(Game.state))
	Game.start_game()


## F11 или Alt+Enter — переключить полный экран и окно (в вебе этим управляет браузер).
func _unhandled_key_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo or OS.has_feature("web"):
		return
	if key.keycode == KEY_F11 or (key.keycode == KEY_ENTER and key.alt_pressed):
		var fullscreen := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if fullscreen else DisplayServer.WINDOW_MODE_FULLSCREEN)
		get_viewport().set_input_as_handled()
