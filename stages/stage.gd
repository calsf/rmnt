extends Node2D

const SHAKE_DECAY_RATE = 5.0
const SHAKE_RANGE = 3

onready var _stage_bg = $StaticBody2D/Background
onready var _fade = get_tree().current_scene.get_node("HUD/Fade")
onready var _random = RandomNumberGenerator.new()

var shake := 0.0

onready var rmnts := [
	get_tree().current_scene.get_node("World/RM001"),
	get_tree().current_scene.get_node("World/RM002"),
	get_tree().current_scene.get_node("World/RM003"),
	get_tree().current_scene.get_node("World/RM004")
]


func _ready():
	# Activate selected rmnt from save data
	var selected_rmnt_i = SaveLoadManager.get_selected_rmnt_i()
	for i in range(rmnts.size()):
		if i == selected_rmnt_i:
			rmnts[i].activate()
			rmnts[i].init_hud()
			
			rmnts[i].connect("died", self, "_on_player_death")
		else:
			rmnts[i].deactivate()
	
	yield(get_tree().create_timer(.4), "timeout")
	MusicGlobal.play("Stage")


func _process(delta):
	shake = lerp(shake, 0, SHAKE_DECAY_RATE * delta)

	_stage_bg.offset = _get_random_offset()


func _on_player_death(rmnt : Player):
	if get_tree().current_scene.has_node("World/DeathOverlay"):
		# Check and save stage score for endless stages
		var stage = $World
		if stage is StageEndless:
			stage.save_stage_score()
		
		# Temporarily process sounds while paused
		SoundsGlobal.pause_mode = Node.PAUSE_MODE_PROCESS
		SoundsGlobal.stop_all()
		SoundsGlobal.play("RmntDeath")
		
		# Pause entire tree
		get_tree().paused = true
		
		# Only process death overlay, active player, and fade
		var death_overlay = get_tree().current_scene.get_node("World/DeathOverlay")
		death_overlay.pause_mode = Node.PAUSE_MODE_PROCESS
		rmnt.pause_mode = Node.PAUSE_MODE_PROCESS
		_fade.pause_mode = Node.PAUSE_MODE_PROCESS
		
		death_overlay.visible = true
		rmnt.z_index = death_overlay.z_index + 1
		
		# Wait for death anim to finish and return to main stage
		yield(rmnt.anim, "animation_finished")
		yield(get_tree().create_timer(.8, true), "timeout")
		
		# Revert pause mode
		SoundsGlobal.pause_mode = Node.PAUSE_MODE_INHERIT
		
		_fade.go_to_scene("res://stages/main/StageMain.tscn")


# Call to shake the stage background
func shake():
	shake = SHAKE_RANGE


# Only shakes vertically
func _get_random_offset():
	if shake == 0:
		return Vector2.ZERO
	else:
		_random.randomize()
		var y = _random.randf_range(-shake, shake)
		return Vector2(0, y)


# For animation
func play_audio(audio_name : String):
	if visible:
		SoundsGlobal.play(audio_name)

