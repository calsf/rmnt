extends EnemyState


func enter(data_state := {}) -> void:
	enemy.disable_hurtbox()
	enemy.disable_all_hitboxes()
	enemy.anim.play("EscapeFrom")


func exit(data_state := {}) -> void:
	# Re-enable hurtbox and reset hitstun related values
	enemy.enable_hurtbox()
	enemy.knockback = Vector2.ZERO
	enemy.knockdown = 0
	enemy.child_velocity = Vector2.ZERO
	enemy.is_aerial_stun = false


func state_physics_process(delta: float) -> void:
	var initial_knockback = enemy.knockback
	enemy.knockback = enemy.knockback.move_toward(Vector2.ZERO, enemy.props.ground_decel * delta)
	enemy.knockback = enemy.move_and_slide(enemy.knockback)
	if enemy.get_slide_count():
		# Bounce only relevant if normal.x is not 0
		if enemy.get_slide_collision(0).normal.x != 0:
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
		state_machine.transition_to("SlamEye")

