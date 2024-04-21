# Custom Move for BSFinal2
extends EnemyState

const MAX_MOVE = 3

export var closest_distance := 3

# Number of times entered Move consecutively
# After MAX_MOVE, reset to 0 and transition to idle
var times_moved = 0


func enter(data_state := {}) -> void:
	if times_moved >= MAX_MOVE:
		times_moved = 0
		state_machine.transition_to("Idle", {
				next_attack = "SlamEye"
			})
		return
	else:
		times_moved += 1
		enemy.anim.play("Move")
		enemy.is_attacking = true


func exit(data_state := {}) -> void:
	# Disable hitboxes?
	pass


func state_physics_process(delta: float) -> void:
	var player = enemy.get_player_target()
	if player.global_position.distance_to(enemy.global_position) > closest_distance:
		enemy.velocity = (player.global_position - enemy.global_position).normalized()
		enemy.velocity.x *= enemy.props.speed_x
		enemy.velocity.y *= enemy.props.speed_y
		enemy.velocity = enemy.move_and_slide(enemy.velocity)
		
		# Apply push if stacked on top of another pushbox area
		var push_vector = enemy.pushbox.get_push_vector()
		enemy.global_position += (push_vector * delta) * enemy.props.speed_x
		enemy.turn(enemy.velocity.x)
	
	if not enemy.trigger_states.empty():
		# Check for and trigger a random trigger state
		if enemy.should_trigger_random_state():
			# Trigger waiting state and reset waiting state
			if not enemy.trigger_states.empty() and enemy.waiting_state != null:
				state_machine.transition_to(enemy.waiting_state.trigger_state_name)
				enemy.waiting_state = null
