extends TestCase


func test_story_keys_exist() -> void:
	for i in Story.item_count():
		var data := Story.item(i)
		if data.after_line_key != "":
			check(Texts.has_key(data.after_line_key), "реплика " + data.after_line_key)
		check(Texts.has_key("item.%s" % data.id), "предмет " + String(data.id))
		for key in data.memory_frames:
			check(Texts.has_key(key), "кадр " + key)
	for key in Story.LAST_DAY_FRAMES:
		check(Texts.has_key(key), "кадр " + key)


func test_story_scenes_registered() -> void:
	var scene_manager: GDScript = load("res://core/scene_manager/scene_manager.gd")
	var scenes: Dictionary = scene_manager.get_script_constant_map()["SCENES"]
	for i in Story.item_count():
		check(scenes.has(Story.item(i).minigame_scene), "сцена мини-игры %d" % i)
	for id in scenes:
		check(ResourceLoader.exists(scenes[id]), "файл сцены " + String(id))


func test_all_languages_have_same_keys() -> void:
	var base := Texts.keys_of(Texts.FALLBACK)
	for code in Texts.LANGUAGES:
		var keys := Texts.keys_of(code)
		for key in base:
			check(keys.has(key), "%s: нет ключа %s" % [code, key])
		for key in keys:
			check(base.has(key), "%s: лишний ключ %s" % [code, key])


func test_language_switch_changes_text() -> void:
	Texts.set_language("ru")
	var ru := Texts.get_text("finale.1")
	Texts.set_language("en")
	var en := Texts.get_text("finale.1")
	Texts.set_language("ru")
	check(ru != en, "тексты на разных языках различаются")
