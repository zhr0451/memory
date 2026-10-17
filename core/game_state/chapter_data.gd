class_name ChapterData extends RefCounted
## Описание главы: предмет, мини-игра, воспоминание, реакция героя.

var id: StringName
var minigame_scene: StringName
var memory_frames: Array[String] = []
var after_line_key: String
var after_emotion: Emotion.Kind


static func create(
		p_id: StringName,
		p_minigame_scene: StringName,
		p_memory_frames: Array[String],
		p_after_line_key: String,
		p_after_emotion: Emotion.Kind) -> ChapterData:
	var data := ChapterData.new()
	data.id = p_id
	data.minigame_scene = p_minigame_scene
	data.memory_frames = p_memory_frames
	data.after_line_key = p_after_line_key
	data.after_emotion = p_after_emotion
	return data
