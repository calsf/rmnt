extends PlayerState

var initial_input_vector : Vector2


func enter(data_state := {}) -> void:
	initial_input_vector = player.get_movement_input()
	
	if initial_input_vector.x == 0 and initial_input_vector.y == 0:
		state_machine.transition_to("Idle")
		return
	
	player.anim.play("Dash")
	player.child_velocity.y = 0


func exit(data_state := {}) -> void:
	player.disable_input_cancel()
	player.disable_all_hitboxes()


func handle_input(event: InputEvent) -> void:
	# Bufferable inputs
	if (not player.can_input_cancel and event.is_action_pressed("attack_a") \
			or event.is_action_pressed("attack_b") \
			or event.is_action_pressed("attack_c") \
			or event.is_action_pressed("jump") \
			or event.is_action_pressed("dash")):
		player.last_input = event
		player.input_timer.start()


func state_physics_process(delta: float) -> void:
	if check_attack_special():
		return
	
	if player.is_aerial_stun:
		state_machine.transition_to("HitstunAir")
		return
	elif player.knockback != Vector2.ZERO:
		state_machine.transition_to("Hitstun")
		return
	
	player.velocity.x = player.props.speed_x_dash * initial_input_vector.x
	player.velocity.y = player.props.speed_y_dash * initial_input_vector.y
	player.velocity = player.move_and_slide(player.velocity)
	player.turn(player.velocity.x)
	
	if player.can_input_cancel:
		if player.get_player_child().is_on_floor():
			if Input.is_action_just_pressed("attack_a") or player.is_input_buffered("attack_a"):
				state_machine.transition_to("AttackA1")
			elif Input.is_action_just_pressed("attack_b") or player.is_input_buffered("attack_b"):
				state_machine.transition_to("AttackB")
			elif Input.is_action_just_pressed("attack_c") or player.is_input_buffered("attack_c"):
				state_machine.transition_to("AttackC")
			elif (Input.is_action_just_pressed("jump") or player.is_input_buffered("jump")):
				state_machine.transition_to("Air", {
					jump = true
				})
		else:
			if Input.is_action_just_pressed("attack_a") or player.is_input_buffered("attack_a"):
				state_machine.transition_to("AirAttackA")
			elif Input.is_action_just_pressed("attack_b") or player.is_input_buffered("attack_b"):
				state_machine.transition_to("AirAttackB")
			elif Input.is_action_just_pressed("attack_c") or player.is_input_buffered("attack_c"):
				state_machine.transition_to("AirAttackC")


	if not player.anim.is_playing():
		if player.get_player_child().is_on_floor():
			if Input.is_action_pressed("move_left") \
			or Input.is_action_pressed("move_right") \
			or Input.is_action_pressed("move_up") \
			or Input.is_action_pressed("move_down"):
				state_machine.transition_to("Move")
			else:
				state_machine.transition_to("Idle")
		else:
			state_machine.transition_to("Air")
