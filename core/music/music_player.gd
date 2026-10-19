class_name MusicPlayer extends AudioStreamPlayer
## Фоновая музыка: один трек на повторе. Включается после выбора языка и играет, пока окно открыто,
## через все экраны (живёт в автозагрузке Game, смена сцен её не трогает).

const TRACK_PATH := "res://shared/audio/music_main.mp3"
const VOLUME_DB := -8.0
const FADE_IN := 2.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var track := load(TRACK_PATH) as AudioStreamMP3
	if track == null:
		return
	track.loop = true
	stream = track


## Запустить трек с плавным появлением. Если уже играет — ничего не делать.
func start() -> void:
	if stream == null or playing:
		return
	volume_db = -40.0
	play()
	create_tween().tween_property(self, "volume_db", VOLUME_DB, FADE_IN)
