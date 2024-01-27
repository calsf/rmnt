# Escape to random position and immediately transition to an attack state
extends EnemyState

# Array of possible attack state names to immediately transition to after escaping
export var attack_states : Array


func enter(data_state := {}) -> void:
	enemy.is_aerial_stun = false
	enemy.knockback = Vector2.ZERO
	enemy.knockdown = 0
	enemy.child_velocity = Vector2.ZERO
	enemy.enemy_child.position = Vector2.ZERO
	
	enemy.anim.play("EscapeTo")
	enemy.global_position = get_random_pos()


func exit(data_state := {}) -> void:
	# Re-enable hurtbox and reset hitstun related values
	enemy.enable_hurtbox()


func state_physics_process(delta: float) -> void:
	if not enemy.anim.is_playing():
		var random_state = randi() % attack_states.size()
		state_machine.transition_to(attack_states[random_state])


func get_random_pos() -> Vector2:
	var random_pos_x = rand_range(enemy.min_x, enemy.max_x)
	var random_pos_y = rand_range(enemy.max_y, enemy.min_y) # "Up" or max_y is lower number
	
	return Vector2(random_pos_x, random_pos_y)
