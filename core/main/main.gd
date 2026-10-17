extends Node
## Точка входа: подключает HUD героя и запускает игру.

const HERO_HUD := preload("res://features/hero_hud/hero_hud.tscn")


func _ready() -> void:
	var hud := HERO_HUD.instantiate() as HeroHudView
	add_child(hud)
	hud.bind(HeroHudViewModel.new(Game.state))
	Game.start_game()
