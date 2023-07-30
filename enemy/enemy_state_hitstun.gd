extends EnemyState


func enter(data_state := {}) -> void:
	enemy.child_velocity.y = 0


func exit(data_state := {}) -> void:
	# Disable hitboxes?
	pass


func state_physics_process(delta: float) -> void:
	# TEMP HITSTUN BEHAVIOR
	if enemy.is_aerial_stun:
			state_machine.transition_to("HitstunAir")
	
	var initial_knockback = enemy.knockback
	enemy.knockback = enemy.knockback.move_toward(Vector2.ZERO, enemy.props.ground_decel * delta)
	enemy.knockback = enemy.move_and_slide(enemy.knockback)
	if enemy.get_slide_count():
		enemy.knockback = initial_knockback.bounce(enemy.get_slide_collision(0).normal) # Bounce
	
	if enemy.knockback == Vector2.ZERO:
		state_machine.transition_to("Idle")
