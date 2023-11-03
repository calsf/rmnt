# Move random for air enemies
# Child body always keep moving towards y
# Finds random position to move to, when close to target, finds new random position to move to
extends EnemyState

export var closest_distance := 3

var random_pos := Vector2(0, 0)


func enter(data_state := {}) -> void:
	random_pos = get_random_pos()
	enemy.anim.play("Move")


func exit(data_state := {}) -> void:
	# Disable hitboxes?
	pass


func state_physics_process(delta: float) -> void:
	# If close to target, find new random position to move towards
	if random_pos.distance_to(enemy.global_position) <= closest_distance:
		random_pos = get_random_pos()
	
	enemy.velocity = (random_pos - enemy.global_position).normalized()
	enemy.velocity.x *= enemy.props.speed_x
	enemy.velocity.y *= enemy.props.speed_y
	enemy.velocity = enemy.move_and_slide(enemy.velocity)
	
	# Apply push if stacked on top of another pushbox area
	var push_vector = enemy.pushbox.get_push_vector()
	enemy.global_position += (push_vector * delta) * enemy.props.speed_x
	enemy.turn(enemy.velocity.x)
	
	# Always move towards a fixed aerial position
	if enemy.enemy_child.position.distance_to(enemy.air_pos) >= .5:
		var dir = Vector2(0, (enemy.air_pos.y - enemy.enemy_child.position.y)).normalized()
		enemy.child_velocity = dir * enemy.props.speed_y
		enemy.child_velocity = enemy.enemy_child.move_and_slide(enemy.child_velocity)
	
	if enemy.is_aerial_stun or enemy.knockback != Vector2.ZERO:
		state_machine.transition_to("Hitstun")
	elif not enemy.trigger_states.empty():
		# Check for and trigger a random trigger state
		if enemy.should_trigger_random_state():
			# Trigger waiting state and reset waiting state
			if not enemy.trigger_states.empty() and enemy.waiting_state != null:
				state_machine.transition_to(enemy.waiting_state.trigger_state_name)
				enemy.waiting_state = null


func get_random_pos() -> Vector2:
	var random_pos_x = rand_range(enemy.min_x, enemy.max_x)
	var random_pos_y = rand_range(enemy.max_y, enemy.min_y) # "Up" or max_y is lower number
	
	return Vector2(random_pos_x, random_pos_y)
