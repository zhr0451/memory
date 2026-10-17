extends Node
## Автозагрузка SceneManager: переходы между экранами с затемнением.
## Экран-сцена может иметь метод setup(params: Dictionary), он вызывается до добавления в дерево.

signal scene_changed(id: StringName)

const SCENES: Dictionary = {
	&"intro": "res://features/intro/intro.tscn",
	&"junkyard": "res://features/junkyard/junkyard.tscn",
	&"minigame_projector": "res://features/minigame_projector/minigame_projector.tscn",
	&"minigame_clock": "res://features/minigame_clock/minigame_clock.tscn",
	&"minigame_tape": "res://features/minigame_tape/minigame_tape.tscn",
	&"memory": "res://features/memory_slideshow/memory_slideshow.tscn",
	&"finale": "res://features/finale/finale.tscn",
}

var _stage: Node
var _fade: ColorRect
var _current: Node
var _busy: bool = false


func _ready() -> void:
	_stage = Node.new()
	_stage.name = "Stage"
	add_child(_stage)
	var layer := CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	_fade = ColorRect.new()
	_fade.color = Color.BLACK
	layer.add_child(_fade)
	_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.modulate.a = 1.0


func change_to(id: StringName, params: Dictionary = {}, fade_out: float = 0.4, fade_in: float = 0.6) -> void:
	if _busy:
		return
	if not SCENES.has(id):
		push_error("SceneManager: неизвестная сцена '%s'" % id)
		return
	_busy = true
	_fade.mouse_filter = Control.MOUSE_FILTER_STOP
	await _fade_to(1.0, fade_out)
	if is_instance_valid(_current):
		_stage.remove_child(_current)
		_current.queue_free()
	var packed := load(SCENES[id]) as PackedScene
	_current = packed.instantiate()
	if _current.has_method("setup"):
		_current.call("setup", params)
	_stage.add_child(_current)
	await _fade_to(0.0, fade_in)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_busy = false
	scene_changed.emit(id)


func _fade_to(alpha: float, time: float) -> void:
	if time <= 0.0:
		_fade.modulate.a = alpha
		return
	var tween := create_tween()
	tween.tween_property(_fade, "modulate:a", alpha, time)
	await tween.finished
