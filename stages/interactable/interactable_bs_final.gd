extends Interactable

var all_cleared := false


func _ready():
	var stage_clears = SaveLoadManager.get_normal_stage_clears()
	all_cleared = true
	for cleared in stage_clears:
		if not cleared:
			all_cleared = false
	
	show_interact_label(false)


func on_interactable_box_overlap(player_interact_box : PlayerInteractBox) -> void:
	if not all_cleared:
		return
	
	var player_interact_box_owner = player_interact_box.owner
	
	# Objects must be in same lane for hurtbox/hitbox interaction
	if lane_collisions:
		for area in lane_collisions:
			if area.owner == player_interact_box_owner:
				is_interactable = true
				show_interact_label(true)
				return
		
		# If reaches here, there was no lane collision
		is_interactable = false
		show_interact_label(false)
	else:
		is_interactable = false
		show_interact_label(false)
