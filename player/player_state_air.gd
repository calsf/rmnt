extends PlayerState

func enter(data_state := {}) -> void:
	if data_state.has("jump"):
		player.anim.play("Jump")
		player.gravity = 0
		player.has_jumped = true
		player.jump_height = player.MAX_HEIGHT + player.added_height
		player.is_jumping = true
		player.is_falling = false
	else:
		player.is_jumping = false
		player.is_falling = true
		player.anim.play("AirIdle")


func exit(data_state := {}) -> void:
	player.disable_input_cancel()
	

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
		if Input.is_action_just_pressed("attack_a") or player.is_input_buffered("attack_a"):
				state_machine.transition_to("AirAttackA")
		elif Input.is_action_just_pressed("attack_b") or player.is_input_buffered("attack_b"):
				state_machine.transition_to("AirAttackB")
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
				
				player.added_height -= player.height_change
				player.player_child.position.y += player.height_change
			else:
				# Reset jump related values
				player.jump_height = player.MAX_HEIGHT
				player.added_height = 0
				player.gravity = 0 	# Reset gravity
				player.is_falling = false
				player.has_jumped = false
				
				if Input.is_action_just_pressed("attack_a") or player.is_input_buffered("attack_a"):
					state_machine.transition_to("AttackA1")
				elif Input.is_action_just_pressed("attack_b") or player.is_input_buffered("attack_b"):
					state_machine.transition_to("AttackB")
				elif Input.is_action_just_pressed("attack_c") or player.is_input_buffered("attack_c"):
					state_machine.transition_to("AttackC")
				elif (Input.is_action_just_pressed("jump") or player.is_input_buffered("jump")) and not player.has_jumped:
					state_machine.transition_to("Air", {
						jump = true
					})
				else:
					state_machine.transition_to("Idle")
