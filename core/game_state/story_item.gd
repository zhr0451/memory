class_name StoryItem extends RefCounted
## Предмет на свалке: к какой главе относится, мини-игра, воспоминание, реакция героя после главы.

var id: StringName
var chapter: int
var minigame_scene: StringName
var memory_frames: Array[String] = []
## Префикс картинок воспоминания: <memory_art>_<a|b|c>.png.
var memory_art: String
## Реплика и эмоция звучат, только если предмет закрывает главу (см. Story.ends_chapter).
var after_line_key: String
var after_emotion: Emotion.Kind


static func create(
		p_id: StringName,
		p_chapter: int,
		p_minigame_scene: StringName,
		p_memory_frames: Array[String],
		p_memory_art: String,
		p_after_line_key: String = "",
		p_after_emotion: Emotion.Kind = Emotion.Kind.JOY) -> StoryItem:
	var item := StoryItem.new()
	item.id = p_id
	item.chapter = p_chapter
	item.minigame_scene = p_minigame_scene
	item.memory_frames = p_memory_frames
	item.memory_art = p_memory_art
	item.after_line_key = p_after_line_key
	item.after_emotion = p_after_emotion
	return item
