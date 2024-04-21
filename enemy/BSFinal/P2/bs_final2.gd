# Custom Enemy for BSFinal2
extends Enemy

onready var stage_main = get_tree().current_scene


func take_damage(dmg : float) -> void:
	curr_hp -= dmg
	emit_signal("health_updated", self)
	
	# Death check
	if curr_hp <= 0:
		# Instance death effect before removing enemy
		var death = load(props.death_path).instance()
		get_tree().current_scene.get_node("World").add_child(death)
		death.global_position = enemy_child.global_position
		Global.add_kill_count()
		emit_signal("died", self)
		
		SoundsGlobal.play(props.death_sound)
		stage_main.trigger_end()
		
		queue_free()
	else:
		activate_hitsparks()
