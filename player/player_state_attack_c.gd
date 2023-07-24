extends PlayerState


func enter(data_state := {}) -> void:
	player.velocity = Vector2.ZERO
	player.anim.play("AttackC")


func exit(data_state := {}) -> void:
	player.disable_input_cancel()
	player.disable_all_hitboxes()


func handle_input(event: InputEvent) -> void:
	# Bufferable inputs
	if (event.is_action_pressed("attack_a") \
			or event.is_action_pressed("attack_b") \
			or event.is_action_pressed("jump")):
		player.last_input = event
		player.input_timer.start()


func state_process(delta: float) -> void:
	if player.can_input_cancel:
		if Input.is_action_just_pressed("attack_a") or player.is_input_buffered("attack_a"):
			state_machine.transition_to("AttackA1")
		elif Input.is_action_just_pressed("attack_b") or player.is_input_buffered("attack_b"):
			state_machine.transition_to("AttackB")
		elif (Input.is_action_just_pressed("jump") or player.is_input_buffered("jump")):
			state_machine.transition_to("Air", {
				jump = true
			})
		
	if not player.anim.is_playing():
		state_machine.transition_to("Idle")
