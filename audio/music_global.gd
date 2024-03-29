extends Node


func _ready():
	update_all_audio_volumes()


func play(audio_name : String) -> void:
	var vol = SaveLoadManager.get_music_vol() / 10.0
	var audio = get_node(audio_name)
	audio.play_with_vol(vol)


func stop(audio_name : String) -> void:
	get_node(audio_name ).stop()


func stop_all() -> void:
	for player in get_children():
		player.stop()


# Update all music audio volume since music audio may already be playing
func update_all_audio_volumes() -> void:
	var vol = SaveLoadManager.get_music_vol() / 10.0
	for audio in get_children():
		audio.set_vol(vol)
