extends Node
## Автозагрузка Game: общее состояние прохождения и порядок экранов.
## Выбор языка → вступление → свалка → мини-игра → воспоминание → свалка … → «последний день» → финал.
## Ошибки садят батарейку; в ноль — экран проигрыша и глава заново.

## Пауза перед экраном проигрыша: дать увидеть, что ответ неверный.
const DEATH_DELAY := 1.2

var state := GameState.new()
var music := MusicPlayer.new()


func _ready() -> void:
	state.battery_dead.connect(_on_battery_dead)
	add_child(music)


func start_game() -> void:
	state.reset()
	SceneManager.change_to(&"language", {}, 0.0, 0.0)


func on_language_chosen() -> void:
	music.start()
	SceneManager.change_to(&"intro", {}, 0.4, 0.4)


func on_item_selected(index: int) -> void:
	SceneManager.change_to(Story.item(index).minigame_scene, {"item": index})


func on_minigame_solved(index: int) -> void:
	if state.is_dead():
		return
	if Story.frames_for(index).is_empty():
		on_memory_finished(index)
	else:
		SceneManager.change_to(&"memory", {"item": index})


func on_memory_finished(index: int) -> void:
	var count := Story.item_count()
	if index >= count:
		SceneManager.change_to(&"finale", {}, 1.2, 1.5)
		return
	var ends_chapter := Story.ends_chapter(index)
	state.complete_item(ends_chapter)
	if ends_chapter:
		var item := Story.item(index)
		state.emotion.value = item.after_emotion
		state.say(item.after_line_key)
	if index + 1 < count:
		SceneManager.change_to(&"junkyard", {"zoom_from": index})
	else:
		if state.current_line.value != "":
			await state.lines_drained
		SceneManager.change_to(&"memory", {"item": count})


## «Попробовать ещё»: GameState уже вернул главу к началу.
func on_retry() -> void:
	SceneManager.change_to(&"junkyard", {}, 0.6, 1.2)


func _on_battery_dead() -> void:
	await get_tree().create_timer(DEATH_DELAY).timeout
	SceneManager.change_to(&"game_over", {}, 1.0, 0.8)
