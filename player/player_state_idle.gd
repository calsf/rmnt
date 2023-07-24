extends PlayerState


func enter(data_state := {}) -> void:
	player.velocity = Vector2.ZERO
	player.anim.play("Idle")


func exit(data_state := {}) -> void:
	player.disable_input_cancel()


func state_process(delta: float) -> void:
	if (Input.is_action_just_pressed("jump") or player.is_input_buffered("jump")) and not player.has_jumped:
		state_machine.transition_to("Air", {
				jump = true
			})
	elif Input.is_action_just_pressed("attack_a"):
		state_machine.transition_to("AttackA1")
	elif Input.is_action_just_pressed("attack_b"):
		state_machine.transition_to("AttackB")
	elif Input.is_action_just_pressed("attack_c"):
		state_machine.transition_to("AttackC")
	elif Input.is_action_pressed("move_left") \
			or Input.is_action_pressed("move_right") \
			or Input.is_action_pressed("move_up") \
			or Input.is_action_pressed("move_down"):
		state_machine.transition_to("Move")
