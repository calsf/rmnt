extends PlayerState


func enter(data_state := {}) -> void:
	player.anim.play("AirAttackA")


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
	
	if player.can_input_cancel:
		if Input.is_action_just_pressed("attack_b") or player.is_input_buffered("attack_b"):
				state_machine.transition_to("AirAttackB")
	
	if not player.anim.is_playing():
		state_machine.transition_to("Air")
