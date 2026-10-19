class_name Story extends RefCounted
## Сюжет: предметы по порядку. Глав 4, в главе может быть несколько предметов;
## батарейка и реплика «после главы» — когда закрыт последний предмет главы.
## Видеокамера (глава 4) пока не сделана: после компьютера идёт «последний день» и финал.

const LAST_DAY_FRAMES: Array[String] = ["mem.4.a", "mem.4.b", "mem.4.c"]
const LAST_DAY_ART := "mem_4"

static var _items: Array[StoryItem] = []


static func items() -> Array[StoryItem]:
	if _items.is_empty():
		_items = _build()
	return _items


static func item_count() -> int:
	return items().size()


static func item(index: int) -> StoryItem:
	return items()[index]


static func chapter_count() -> int:
	return items().back().chapter


## Предмет последний в своей главе.
static func ends_chapter(index: int) -> bool:
	return index + 1 >= item_count() or item(index + 1).chapter != item(index).chapter


## Кадры воспоминания; индекс item_count() — «последний день».
static func frames_for(index: int) -> Array[String]:
	if index >= item_count():
		return LAST_DAY_FRAMES
	return item(index).memory_frames


static func art_for(index: int) -> String:
	if index >= item_count():
		return LAST_DAY_ART
	return item(index).memory_art


static func _build() -> Array[StoryItem]:
	var result: Array[StoryItem] = []
	result.append(StoryItem.create(&"projector", 1, &"minigame_projector",
			["mem.1.a", "mem.1.b", "mem.1.c"], "mem_1"))
	result.append(StoryItem.create(&"phone", 1, &"minigame_phone",
			["mem.phone.a", "mem.phone.b"], "mem_phone", "after.1", Emotion.Kind.JOY))
	result.append(StoryItem.create(&"clock", 2, &"minigame_clock",
			["mem.2.a", "mem.2.b", "mem.2.c"], "mem_2", "after.2", Emotion.Kind.WORRY))
	result.append(StoryItem.create(&"radio", 3, &"minigame_radio",
			["mem.3.a", "mem.3.b"], "mem_3", "after.3", Emotion.Kind.DOUBT))
	# Своего воспоминания у компьютера нет: открытие — файл «ПЕРЕЕЗД.TXT» на экране.
	result.append(StoryItem.create(&"computer", 4, &"minigame_computer",
			[], "", "after.4", Emotion.Kind.FEAR))
	return result
