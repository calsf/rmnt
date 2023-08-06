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
			or event.is_action_pressed("jump") \
			or event.is_action_pressed("dash")):
		player.last_input = event
		player.input_timer.start()


func state_physics_process(delta: float) -> void:
	if player.is_aerial_stun:
		state_machine.transition_to("HitstunAir")
		return
	elif player.knockback != Vector2.ZERO:
		state_machine.transition_to("Hitstun")
		return
	
	# Do not allow turning during air attack
	player.update_movement(false)
	
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
		elif Input.is_action_just_pressed("dash") or player.is_input_buffered("dash"):
			state_machine.transition_to("Dash")
		else:
			state_machine.transition_to("Idle")

	if player.can_input_cancel:
		if Input.is_action_just_pressed("attack_a") or player.is_input_buffered("attack_a"):
			state_machine.transition_to("AirAttackA")
		elif Input.is_action_just_pressed("attack_c") or player.is_input_buffered("attack_c"):
			state_machine.transition_to("AirAttackC")
		elif Input.is_action_just_pressed("dash") or player.is_input_buffered("dash"):
			state_machine.transition_to("Dash")
	
	if not player.anim.is_playing():
		state_machine.transition_to("Air")
