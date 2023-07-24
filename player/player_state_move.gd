extends PlayerState

func enter(data_state := {}) -> void:
	var input_vector = player.get_movement_input()

	if input_vector.x == 0 and input_vector.y == 0:
		state_machine.transition_to("Idle")
		return
	
	owner.anim.play("Move")


func exit(data_state := {}) -> void:
	player.disable_input_cancel()


func state_physics_process(delta: float) -> void:
	var input_vector = owner.update_movement()

	if Input.is_action_just_pressed("jump") and not owner.has_jumped:
		state_machine.transition_to("Air", {
				jump = true
			})
	elif input_vector.x == 0 and input_vector.y == 0:
		state_machine.transition_to("Idle")
	elif Input.is_action_just_pressed("attack_a"):
		state_machine.transition_to("AttackA1")
	elif Input.is_action_just_pressed("attack_b"):
		state_machine.transition_to("AttackB")
	elif Input.is_action_just_pressed("attack_c"):
		state_machine.transition_to("AttackC")
