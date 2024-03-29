extends Node


func _ready():
	update_all_audio_volumes()


func play(audio_name : String) -> void:
	var vol = SaveLoadManager.get_sound_vol() / 10.0
	var audio = get_node(audio_name)
	audio.play_with_vol(vol)


# Only for initialization, do not need to update sound vol while it's already playing
func update_all_audio_volumes() -> void:
	var vol = SaveLoadManager.get_sound_vol() / 10.0
	for audio in get_children():
		audio.set_vol(vol)
