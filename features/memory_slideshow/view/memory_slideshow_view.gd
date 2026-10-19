class_name MemorySlideshowView extends Control
## Воспоминание: кадр на весь экран, подпись внизу, покачивание и медленный наезд.
## Картинка — <Story.art_for(предмет)>.png (например mem_1.png), одна на все подписи воспоминания:
## между подписями она не перезапускается, меняется только текст.
## Если есть покадровые <art>_<a|b|c>.png — берутся они; иначе тёплая заглушка.

const ASSET_DIR := "res://features/memory_slideshow/assets/"
const PALETTE: Array[Color] = [Color("d9a05b"), Color("c98a4b"), Color("e0b070"), Color("b87a3e")]
const BASE_SCALE := 1.05
const ZOOM_EXTRA := 0.06
const ZOOM_TIME := 10.0
const SWAY_DEGREES := 0.4
const FADE_TIME := 0.5
const INPUT_LOCK := 0.7

var _vm: MemorySlideshowViewModel
var _item: int = 0
var _frame: Control
var _caption: Label
var _hint: Label
var _frame_time: float = 0.0
## Время на текущей картинке: наезд и покачивание идут от него и не сбрасываются, пока картинка та же.
var _picture_time: float = 0.0
var _picture_key: String = ""


func setup(params: Dictionary) -> void:
	_item = params.get("item", 0)


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var backdrop := ColorRect.new()
	backdrop.color = Color("2a1d12")
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_frame = Control.new()
	_frame.size = Vector2(1920, 1080)
	_frame.pivot_offset = _frame.size * 0.5
	_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_frame)
	_build_caption()
	bind(MemorySlideshowViewModel.new(Game.state, _item))


func bind(vm: MemorySlideshowViewModel) -> void:
	_vm = vm
	vm.frame_index.changed.connect(func(_i: int) -> void: _show_frame())
	vm.finished.connect(func() -> void: Game.on_memory_finished(_item))
	vm.activate()
	_show_frame()


func _process(delta: float) -> void:
	_frame_time += delta
	_picture_time += delta
	var progress := minf(_picture_time / ZOOM_TIME, 1.0)
	_frame.scale = Vector2.ONE * (BASE_SCALE + ZOOM_EXTRA * progress)
	_frame.rotation = sin(_picture_time * 0.6) * deg_to_rad(SWAY_DEGREES)


func _input(event: InputEvent) -> void:
	if AdvanceInput.is_advance(event) and _frame_time >= INPUT_LOCK:
		_vm.next()
		get_viewport().set_input_as_handled()


func _build_caption() -> void:
	var box := PanelContainer.new()
	box.position = Vector2(360, 880)
	box.custom_minimum_size = Vector2(1200, 0)
	box.size = Vector2(1200, 0)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.07, 0.04, 0.82)
	style.border_color = Color("e0b070")
	style.set_border_width_all(3)
	style.set_corner_radius_all(14)
	style.set_content_margin_all(20)
	box.add_theme_stylebox_override("panel", style)
	_caption = Label.new()
	_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_caption.add_theme_font_size_override("font_size", 40)
	_caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(_caption)
	add_child(box)
	_hint = Label.new()
	_hint.text = Texts.get_text("ui.next")
	_hint.position = Vector2(1560, 1020)
	_hint.modulate.a = 0.0
	_hint.add_theme_font_size_override("font_size", 24)
	_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_hint)


func _show_frame() -> void:
	var index: int = _vm.frame_index.value
	var key := _picture_path(index)
	if key == "":
		key = "stand_in_%d" % index
	_caption.text = _vm.caption()
	_frame_time = 0.0
	var tween := create_tween().set_parallel()
	if key != _picture_key:
		_picture_key = key
		_picture_time = 0.0
		for child in _frame.get_children():
			child.queue_free()
		_frame.add_child(_make_picture(index))
		_frame.modulate.a = 0.0
		tween.tween_property(_frame, "modulate:a", 1.0, FADE_TIME)
	else:
		_caption.modulate.a = 0.0
		tween.tween_property(_caption, "modulate:a", 1.0, FADE_TIME)
	_hint.modulate.a = 0.0
	tween.tween_property(_hint, "modulate:a", 0.55, 1.0).set_delay(1.5)


## Покадровая картинка, если есть, иначе общая на воспоминание; "" — арта нет.
func _picture_path(index: int) -> String:
	var art := Story.art_for(_item)
	var per_frame := "%s%s_%s.png" % [ASSET_DIR, art, "abc"[index]]
	if ResourceLoader.exists(per_frame):
		return per_frame
	var shared := "%s%s.png" % [ASSET_DIR, art]
	if ResourceLoader.exists(shared):
		return shared
	return ""


func _make_picture(index: int) -> Control:
	var path := _picture_path(index)
	if path != "":
		var picture := TextureRect.new()
		picture.texture = load(path) as Texture2D
		picture.size = _frame.size
		picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
		return picture
	var stand_in := ColorRect.new()
	stand_in.color = PALETTE[(_item + index) % PALETTE.size()]
	stand_in.size = _frame.size
	stand_in.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return stand_in
