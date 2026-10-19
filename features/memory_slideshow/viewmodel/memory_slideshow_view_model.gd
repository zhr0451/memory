class_name MemorySlideshowViewModel extends ViewModel
## Слайд-шоу воспоминания: кадры с подписями, «клик — дальше».

signal finished

## Индекс предмета; item_count() — «последний день».
var item: int
var frame_index := Observable.new(0)
var frames: Array[String]

var _state: GameState
var _done: bool = false


func _init(state: GameState, p_item: int) -> void:
	_state = state
	item = p_item
	frames = Story.frames_for(p_item)


func activate() -> void:
	_state.emotion.value = Emotion.Kind.MEMORY


func caption() -> String:
	return Texts.get_text(frames[frame_index.value])


func next() -> void:
	if _done:
		return
	if frame_index.value + 1 < frames.size():
		frame_index.value += 1
	else:
		_done = true
		finished.emit()
