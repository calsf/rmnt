extends PlayerState


func enter(data_state := {}) -> void:
	pass


func exit(data_state := {}) -> void:
	player.is_aerial_stun = false


func state_physics_process(delta: float) -> void:
	var initial_knockback = player.knockback
	player.knockback = player.knockback.move_toward(Vector2.ZERO, player.props.ground_decel * delta)
	player.knockback = player.move_and_slide(player.knockback)
	if player.get_slide_count():
		# Bounce only relevant if normal.x is not 0
		if player.get_slide_collision(0).normal.x != 0:
			player.knockback = initial_knockback.bounce(player.get_slide_collision(0).normal) # Bounce
	
	if not player.is_aerial_stun and player.knockback != Vector2.ZERO:
		return
	
	if player.knockdown > 0:
		player.child_velocity.y = player.knockdown
	
	var initial_child_velocity = player.child_velocity
	player.child_velocity.y += player.GRAVITY * delta
	player.child_velocity = player.get_player_child().move_and_slide(player.child_velocity, Vector2.UP)
	if player.get_player_child().get_slide_count() and player.knockdown > 0:
		player.child_velocity = initial_child_velocity.bounce(player.get_player_child().get_slide_collision(0).normal) * 0.5
		player.knockdown = 0
		return
	
	if player.get_player_child().is_on_floor():
		player.knockdown = 0
		player.is_aerial_stun = false
		if player.knockback == Vector2.ZERO:
			state_machine.transition_to("Idle")
		else:
			state_machine.transition_to("Hitstun")
