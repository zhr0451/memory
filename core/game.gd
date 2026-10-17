extends Node
## Автозагрузка Game: общее состояние прохождения и порядок экранов.
## Свалка → мини-игра → воспоминание → свалка … → «последний день» → финал.

var state := GameState.new()


func start_game() -> void:
	state.reset()
	SceneManager.change_to(&"intro", {}, 0.0, 0.0)


func on_chapter_selected(chapter: int) -> void:
	SceneManager.change_to(Story.chapter(chapter).minigame_scene, {"chapter": chapter})


func on_minigame_solved(chapter: int) -> void:
	SceneManager.change_to(&"memory", {"chapter": chapter})


func on_memory_finished(chapter: int) -> void:
	var count := Story.chapter_count()
	if chapter >= count:
		SceneManager.change_to(&"finale", {}, 1.2, 1.5)
		return
	var data := Story.chapter(chapter)
	state.complete_chapter()
	state.emotion.value = data.after_emotion
	state.say(data.after_line_key)
	if chapter + 1 < count:
		SceneManager.change_to(&"junkyard", {"zoom_from": chapter})
	else:
		await state.lines_drained
		SceneManager.change_to(&"memory", {"chapter": count})
