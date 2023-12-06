extends PlayerState


func enter(data_state := {}) -> void:
	player.velocity = Vector2.ZERO
	player.anim.play("Idle")


func exit(data_state := {}) -> void:
	player.disable_input_cancel()


func state_process(delta: float) -> void:
	check_attack_special()
	
	if player.is_aerial_stun:
		state_machine.transition_to("HitstunAir")
		return
	elif player.knockback != Vector2.ZERO:
		state_machine.transition_to("Hitstun")
		return
	
	if not player.get_player_child().is_on_floor():
		state_machine.transition_to("Air")
	elif (Input.is_action_just_pressed("jump") or player.is_input_buffered("jump")):
		state_machine.transition_to("Air", {
				jump = true
			})
	elif Input.is_action_pressed("move_left") \
			or Input.is_action_pressed("move_right") \
			or Input.is_action_pressed("move_up") \
			or Input.is_action_pressed("move_down"):
		state_machine.transition_to("Move")
	elif Input.is_action_just_pressed("dash"):
		state_machine.transition_to("Dash")
	elif Input.is_action_just_pressed("attack_a"):
		state_machine.transition_to("AttackA1")
	elif Input.is_action_just_pressed("attack_b"):
		state_machine.transition_to("AttackB")
	elif Input.is_action_just_pressed("attack_c"):
		state_machine.transition_to("AttackC")
