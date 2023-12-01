extends Node2D

onready var rmnts := [
	get_tree().current_scene.get_node("World/RM001"),
	get_tree().current_scene.get_node("World/RM002"),
	get_tree().current_scene.get_node("World/RM003"),
	get_tree().current_scene.get_node("World/RM004")
]


func _ready():
	# Activate selected rmnt from save data
	var selected_rmnt_i = SaveLoadManager.get_save_data("selected_rmnt_i")
	for i in range(rmnts.size()):
		if i == selected_rmnt_i:
			rmnts[i].activate()
			rmnts[i].init_hud()
		else:
			rmnts[i].deactivate()
