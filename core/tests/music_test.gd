extends TestCase


func test_track_is_loadable_mp3() -> void:
	var track := load(MusicPlayer.TRACK_PATH) as AudioStreamMP3
	check(track != null, "трек грузится как MP3")
	check(track.get_length() > 60.0, "трек длиннее минуты")
