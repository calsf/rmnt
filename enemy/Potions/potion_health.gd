extends Enemy


func take_damage(dmg : float) -> void:
	curr_hp -= dmg
	emit_signal("health_updated", self)
	
	# Death check
	if curr_hp <= 0:
		# Instance death effect before removing enemy
		var death = load("res://enemy/PotionHealthDeath.tscn").instance()
		get_tree().current_scene.get_node("World").add_child(death)
		death.global_position = enemy_child.global_position
		emit_signal("died", self)
		
		# Heal player on death
		var player = get_player_target()
		player.gain_health(player.props.max_hp / 3.0)
		
		queue_free()
