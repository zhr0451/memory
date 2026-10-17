class_name GameState extends RefCounted
## Состояние прохождения: пройденные главы, лицо, батарейка и очередь реплик героя.

signal lines_drained

const MAX_BATTERY := 4

var chapters_done := Observable.new(0)
var emotion := Observable.new(Emotion.Kind.OFF)
var battery := Observable.new(MAX_BATTERY)
var face_on := Observable.new(false)
var hud_visible := Observable.new(false)
var clock_note_found := Observable.new(false)
var current_line := Observable.new("")

var _queue: Array[String] = []


## Предмет доступен, только если он следующий по сюжету.
func is_item_available(index: int) -> bool:
	return index == chapters_done.value


func complete_chapter() -> void:
	chapters_done.value += 1
	battery.value = maxi(0, MAX_BATTERY - chapters_done.value)


## Реплика героя по ключу текста; печатается по очереди.
func say(key: String) -> void:
	_queue.append(Texts.get_text(key))
	if current_line.value == "":
		_next_line()


## View сообщает, что текущая реплика показана.
func finish_line() -> void:
	_next_line()


func reset() -> void:
	_queue.clear()
	chapters_done.value = 0
	emotion.value = Emotion.Kind.OFF
	battery.value = MAX_BATTERY
	face_on.value = false
	hud_visible.value = false
	clock_note_found.value = false
	current_line.value = ""


func _next_line() -> void:
	if _queue.is_empty():
		current_line.value = ""
		lines_drained.emit()
	else:
		current_line.value = _queue.pop_front()
