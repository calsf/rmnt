extends EnemyState

export var closest_distance := 3


func enter(data_state := {}) -> void:
	enemy.anim.play("Move")


func exit(data_state := {}) -> void:
	# Disable hitboxes?
	pass


func state_physics_process(delta: float) -> void:
	var player = enemy.players[0]
	if player.global_position.distance_to(enemy.global_position) > closest_distance:
		enemy.velocity = (player.global_position - enemy.global_position).normalized() * enemy.props.speed_x
		enemy.velocity = enemy.move_and_slide(enemy.velocity)
		
		# Apply push if stacked on top of another pushbox area
		var push_vector = enemy.pushbox.get_push_vector()
		enemy.global_position += (push_vector * delta) * enemy.props.speed_x
		enemy.turn(enemy.velocity.x)
	
	if not enemy.enemy_child.is_on_floor():
		state_machine.transition_to("HitstunAir")
	elif enemy.is_aerial_stun:
		state_machine.transition_to("HitstunAir")
	elif enemy.knockback != Vector2.ZERO:
		state_machine.transition_to("Hitstun")
	elif not enemy.trigger_states.empty():
		# Check for and trigger a random trigger state
		if enemy.should_trigger_random_state():
			# Trigger waiting state and reset waiting state
			if not enemy.trigger_states.empty() and enemy.waiting_state != null:
				state_machine.transition_to(enemy.waiting_state.trigger_state_name)
				enemy.waiting_state = null
