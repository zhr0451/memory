class_name Story extends RefCounted
## Сюжет: главы по порядку. Видеокамера (глава 4) пока вырезана: после плеера идёт «последний день» и финал.

const LAST_DAY_FRAMES: Array[String] = ["mem.4.a", "mem.4.b", "mem.4.c"]

static var _chapters: Array[ChapterData] = []


static func chapters() -> Array[ChapterData]:
	if _chapters.is_empty():
		_chapters = _build()
	return _chapters


static func chapter_count() -> int:
	return chapters().size()


static func chapter(index: int) -> ChapterData:
	return chapters()[index]


## Кадры воспоминания; индекс chapter_count() — «последний день».
static func frames_for(index: int) -> Array[String]:
	if index >= chapter_count():
		return LAST_DAY_FRAMES
	return chapter(index).memory_frames


static func _build() -> Array[ChapterData]:
	var result: Array[ChapterData] = []
	result.append(ChapterData.create(&"projector", &"minigame_projector",
			["mem.1.a", "mem.1.b", "mem.1.c"], "after.1", Emotion.Kind.JOY))
	result.append(ChapterData.create(&"clock", &"minigame_clock",
			["mem.2.a", "mem.2.b", "mem.2.c"], "after.2", Emotion.Kind.WORRY))
	result.append(ChapterData.create(&"tape", &"minigame_tape",
			["mem.3.a", "mem.3.b"], "after.3", Emotion.Kind.DOUBT))
	return result
