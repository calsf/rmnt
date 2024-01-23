extends Node2D

onready var _fade = get_tree().current_scene.get_node("HUD/Fade")

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


func _on_player_death(rmnt : Player):
	if get_tree().current_scene.has_node("World/DeathOverlay"):
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
		_fade.go_to_scene("res://stages/main/StageMain.tscn")
		
