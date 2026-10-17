extends TestCase


func test_story_keys_exist() -> void:
	for i in Story.chapter_count():
		var data := Story.chapter(i)
		check(Texts.has_key(data.after_line_key), "реплика " + data.after_line_key)
		check(Texts.has_key("item.%s" % data.id), "предмет " + String(data.id))
		for key in data.memory_frames:
			check(Texts.has_key(key), "кадр " + key)
	for key in Story.LAST_DAY_FRAMES:
		check(Texts.has_key(key), "кадр " + key)


func test_story_scenes_registered() -> void:
	var scene_manager: GDScript = load("res://core/scene_manager/scene_manager.gd")
	var scenes: Dictionary = scene_manager.get_script_constant_map()["SCENES"]
	for i in Story.chapter_count():
		check(scenes.has(Story.chapter(i).minigame_scene), "сцена мини-игры %d" % i)
	for id in scenes:
		check(ResourceLoader.exists(scenes[id]), "файл сцены " + String(id))
