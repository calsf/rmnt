extends Node


func _ready():
	update_all_audio_volumes()


func play(audio_name : String, stop_all := true) -> void:
	if stop_all:
		stop_all()
	var audio = get_node(audio_name)
	audio.play()


func stop(audio_name : String) -> void:
	get_node(audio_name ).stop()


func stop_all() -> void:
	for player in get_children():
		player.stop()


# Update all music audio volume since music audio may already be playing
# Only need to update on initialization and when changing setting
func update_all_audio_volumes() -> void:
	var vol = SaveLoadManager.get_music_vol() / 10.0
	for audio in get_children():
		audio.set_vol(vol)
