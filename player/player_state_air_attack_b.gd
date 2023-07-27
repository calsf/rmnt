extends PlayerState


func enter(data_state := {}) -> void:
	player.anim.play("AirAttackB")


func exit(data_state := {}) -> void:
	player.disable_input_cancel()
	player.disable_all_hitboxes()


func handle_input(event: InputEvent) -> void:
	# Bufferable inputs
	if (event.is_action_pressed("attack_a") \
			or event.is_action_pressed("attack_b") \
			or event.is_action_pressed("attack_c") \
			or event.is_action_pressed("jump")):
		player.last_input = event
		player.input_timer.start()


func state_physics_process(delta: float) -> void:
	player.update_movement()
	
	player.child_velocity.y += player.GRAVITY * delta
	player.child_velocity = player.player_child.move_and_slide(player.child_velocity, Vector2.UP)
	
	if player.player_child.is_on_floor():
		if Input.is_action_just_pressed("attack_a"):
			state_machine.transition_to("AttackA1")
		elif Input.is_action_just_pressed("attack_b"):
			state_machine.transition_to("AttackB")
		elif Input.is_action_just_pressed("attack_c"):
			state_machine.transition_to("AttackC")
		elif (Input.is_action_just_pressed("jump") or player.is_input_buffered("jump")):
			state_machine.transition_to("Air", {
				jump = true
			})
		else:
			state_machine.transition_to("Idle")

	if player.can_input_cancel:
		if Input.is_action_just_pressed("attack_a") or player.is_input_buffered("attack_a"):
				state_machine.transition_to("AirAttackA")
	
	if not player.anim.is_playing():
		state_machine.transition_to("Air")
