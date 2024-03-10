extends Node


func _ready():
	# Display or hide boss heads based on whether or not corresponding stage cleared
	var stage_clears = SaveLoadManager.get_normal_stage_clears()
	var heads = get_children()
	for i in range(0, heads.size()):
		if stage_clears[i]:
			heads[i].visible = true
		else:
			heads[i].visible = false

