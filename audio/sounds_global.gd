extends Node

onready var enemy_hit_audio = [
		get_node("EnemyHit001"),
		get_node("EnemyHit002"),
		get_node("EnemyHit003")
	]

onready var enemy_hit_armored_audio = [
		get_node("EnemyHitArmored001"),
		get_node("EnemyHitArmored002"),
		get_node("EnemyHitArmored003")
	]
#var curr_enemy_hit = 0


func _ready():
	update_all_audio_volumes()


func play(audio_name : String) -> void:
	var audio = get_node(audio_name)
	audio.play()


func play_enemy_hit() -> void:
	# Rotate through enemy hit audio
#	enemy_hit_audio[curr_enemy_hit].play()
#	curr_enemy_hit += 1
#	if curr_enemy_hit > enemy_hit_audio.size() - 1:
#		curr_enemy_hit = 0
	
	# Play random enemy hit audio
	enemy_hit_audio[randi() % enemy_hit_audio.size()].play()


func play_enemy_hit_armored() -> void:
	# Play random enemy hit armored audio
	enemy_hit_armored_audio[randi() % enemy_hit_armored_audio.size()].play()


func stop_all() -> void:
	for player in get_children():
		player.stop()


# Only need to update on initialization and when changing setting
func update_all_audio_volumes() -> void:
	var vol = SaveLoadManager.get_sound_vol() / 10.0
	for audio in get_children():
		audio.set_vol(vol)
