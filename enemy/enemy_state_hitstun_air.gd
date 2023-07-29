extends EnemyState


func enter(data_state := {}) -> void:
	pass


func exit(data_state := {}) -> void:
	# Disable hitboxes?
	pass


func state_physics_process(delta: float) -> void:
	# TEMP HITSTUN BEHAVIOR
	var initial_knockback = enemy.knockback
	enemy.knockback = enemy.knockback.move_toward(Vector2.ZERO, enemy.props.ground_decel * delta)
	enemy.knockback = enemy.move_and_slide(enemy.knockback)
	if enemy.get_slide_count():
		enemy.knockback = initial_knockback.bounce(enemy.get_slide_collision(0).normal) # Bounce
	
	if not enemy.is_aerial_stun and enemy.knockback != Vector2.ZERO:
		return
	
	if enemy.knockdown > 0:
		enemy.child_velocity.y = enemy.knockdown
	
	var initial_child_velocity = enemy.child_velocity
	enemy.child_velocity.y += enemy.GRAVITY * delta
	enemy.child_velocity = enemy.enemy_child.move_and_slide(enemy.child_velocity, Vector2.UP)
	if enemy.enemy_child.get_slide_count() and enemy.knockdown > 0:
		enemy.child_velocity = initial_child_velocity.bounce(enemy.enemy_child.get_slide_collision(0).normal) * 0.5
		enemy.knockdown = 0
		return
	
	if enemy.enemy_child.is_on_floor():
		enemy.knockdown = 0
		enemy.is_aerial_stun = false
		state_machine.transition_to("Idle")
