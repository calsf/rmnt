# Move random for air enemies, position is always opposite x position from player
# Enemy hugs stage edges, tries to move away from player when player is too close
# Child body always keep moving towards y
# Finds random position to move to, when close to target, finds new random position to move to
extends EnemyState

# The amount of x distance that enemy past their stage x bound
# This is to avoid enemy being stuck at the edge of the stage
const DIST_VARIATION = 30

export var closest_distance := 3

var is_moving_right := false
var random_pos := Vector2(0, 0)


func enter(data_state := {}) -> void:
	random_pos = get_random_pos()
	enemy.anim.play("Move")


func exit(data_state := {}) -> void:
	# Disable hitboxes?
	pass


func state_physics_process(delta: float) -> void:
	var player = enemy.get_player_target()
	
	# If close to target, find new random position to move towards
	# If player also ends up being closer to the side enemy is moving towards, find new pos
	if random_pos.distance_to(enemy.global_position) <= closest_distance:
		random_pos = get_random_pos()
	elif (abs(player.global_position.x - enemy.min_x) < abs(player.global_position.x - enemy.max_x) \
				and not is_moving_right) or \
			(abs(player.global_position.x - enemy.min_x) > abs(player.global_position.x - enemy.max_x) \
				and is_moving_right):
		random_pos = get_random_pos(true)
	
	enemy.velocity = (random_pos - enemy.global_position).normalized()
	enemy.velocity.x *= enemy.props.speed_x
	enemy.velocity.y *= enemy.props.speed_y
	enemy.velocity = enemy.move_and_slide(enemy.velocity)
	
	# Apply push if stacked on top of another pushbox area
	var push_vector = enemy.pushbox.get_push_vector()
	enemy.global_position += (push_vector * delta) * enemy.props.speed_x
	enemy.turn(enemy.velocity.x)
	
	# Air specific behavior
	# Always move towards a fixed aerial position
	# Check for aerial stun to avoid overwriting y child velocity
	if not enemy.is_aerial_stun and enemy.enemy_child.position.distance_to(enemy.air_pos) >= .5:
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


func get_random_pos(side_swap := false) -> Vector2:
	var player = enemy.get_player_target()
	var random_pos_x = 0
	var random_pos_y = 0
	
	# If player is closer to left, go right
	# Else if player is closer to right, go left
	# Random position x always away from player
	# Allow enemy to be able to move some DIST_VARIATION from bound
	if abs(player.global_position.x - enemy.min_x) < abs(player.global_position.x - enemy.max_x):
		# If enemy is closer to left than player, keep moving to same position
		if side_swap and abs(player.global_position.x - enemy.min_x) > abs(enemy.global_position.x - enemy.min_x):
			return random_pos
		
		# Go stage right side
		random_pos_x = rand_range(enemy.max_x - DIST_VARIATION, enemy.max_x)
		random_pos_y = rand_range(enemy.max_y, enemy.min_y) # "Up" or max_y is lower number
		is_moving_right = true
	else:
		# If enemy is closer to right than player, keep moving to same position
		if side_swap and abs(player.global_position.x - enemy.max_x) > abs(enemy.global_position.x - enemy.max_x):
			return random_pos
		
		# Go stage left side
		random_pos_x = rand_range(enemy.min_x, enemy.min_x + DIST_VARIATION)
		random_pos_y = rand_range(enemy.max_y, enemy.min_y) # "Up" or max_y is lower number
		is_moving_right = false
	
	return Vector2(random_pos_x, random_pos_y)
