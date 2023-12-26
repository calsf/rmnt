extends PlayerState


func enter(data_state := {}) -> void:
	player.child_velocity.y = 0


func exit(data_state := {}) -> void:
	# Disable hitboxes?
	pass


func state_physics_process(delta: float) -> void:
	if check_attack_special():
		return
	
	if player.is_aerial_stun:
		state_machine.transition_to("HitstunAir")
	
	var initial_knockback = player.knockback
	player.knockback = player.knockback.move_toward(Vector2.ZERO, player.props.ground_decel * delta)
	player.knockback = player.move_and_slide(player.knockback)
	if player.get_slide_count():
		# Bounce only relevant if normal.x is not 0
		if player.get_slide_collision(0).normal.x != 0:
			player.knockback = initial_knockback.bounce(player.get_slide_collision(0).normal) # Bounce
	
	if player.knockback == Vector2.ZERO:
		state_machine.transition_to("Idle")
