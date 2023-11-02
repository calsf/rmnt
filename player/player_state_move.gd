extends PlayerState

func enter(data_state := {}) -> void:
	var input_vector = player.get_movement_input()

	if input_vector.x == 0 and input_vector.y == 0:
		state_machine.transition_to("Idle")
		return
	
	player.anim.play("Move")


func exit(data_state := {}) -> void:
	player.disable_input_cancel()


func state_physics_process(delta: float) -> void:
	if player.is_aerial_stun:
		state_machine.transition_to("HitstunAir")
		return
	elif player.knockback != Vector2.ZERO:
		state_machine.transition_to("Hitstun")
		return
	
	var input_vector = owner.update_movement()

	if not player.get_player_child().is_on_floor():
		state_machine.transition_to("Air")
	elif Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Air", {
				jump = true
			})
	elif Input.is_action_just_pressed("dash"):
		state_machine.transition_to("Dash")
	elif input_vector.x == 0 and input_vector.y == 0:
		state_machine.transition_to("Idle")
	elif Input.is_action_just_pressed("attack_a"):
		state_machine.transition_to("AttackA1")
	elif Input.is_action_just_pressed("attack_b"):
		state_machine.transition_to("AttackB")
	elif Input.is_action_just_pressed("attack_c"):
		state_machine.transition_to("AttackC")
