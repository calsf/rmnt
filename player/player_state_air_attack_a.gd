extends PlayerState


func enter(data_state := {}) -> void:
	player.anim.play("AirAttackA")


func exit(data_state := {}) -> void:
	player.disable_input_cancel()
	player.disable_all_hitboxes()


func handle_input(event: InputEvent) -> void:
	# Bufferable inputs
	if player.is_falling and \
			(event.is_action_pressed("attack_a") \
			or event.is_action_pressed("attack_b") \
			or event.is_action_pressed("attack_c") \
			or event.is_action_pressed("jump")):
		player.last_input = event
		player.input_timer.start()


func state_physics_process(delta: float) -> void:
	player.update_movement()
	
	if player.is_jumping or player.is_falling:
		if player.can_input_cancel:
			if Input.is_action_just_pressed("attack_b") or player.is_input_buffered("attack_b"):
					state_machine.transition_to("AirAttackB")
		
		if not player.anim.is_playing():
			state_machine.transition_to("Air")
		
		if player.is_jumping:
			# Increase added height until reaches jump height
			# Move player sprite up the same amount
			if player.added_height < player.jump_height:
				player.gravity += .025 # Apply increasing rise speed
				# Avoid jumping above jump height
				player.height_change = min(player.RISE_SPEED + player.gravity, player.jump_height - player.added_height)
				
				player.added_height += player.height_change
				player.player_child.position.y -= player.height_change
			else:
				player.gravity = 0
				player.is_falling = true	# Once jump_height is reached, set to falling state
				player.is_jumping = false	# No longer in jump state
		elif player.is_falling:
			# Subtract from added height until reaches 0 or less
			# Move player sprite down the same amount
			if player.added_height > 0:
				player.gravity += .025	# Apply increasing gravity force
				player.height_change = player.FALL_SPEED + player.gravity
				# Avoid added_height going below 0
				if player.added_height - player.height_change < 0:
					player.height_change = player.added_height
				
				player.height_change /= 3
				
				player.added_height -= player.height_change
				player.player_child.position.y += player.height_change
			else:
				# Reset jump related values
				player.jump_height = player.MAX_HEIGHT
				player.added_height = 0
				player.gravity = 0 	# Reset gravity
				player.is_falling = false
				player.has_jumped = false
				
				state_machine.transition_to("Idle")
