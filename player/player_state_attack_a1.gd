extends PlayerState

export var armored := false


func enter(data_state := {}) -> void:
	player.velocity = Vector2.ZERO
	player.anim.play("AttackA1")
	player.armored = self.armored


func exit(data_state := {}) -> void:
	player.disable_input_cancel()
	player.disable_all_hitboxes()
	player.armored = false


func handle_input(event: InputEvent) -> void:
	# Bufferable inputs
	if (not player.can_input_cancel and event.is_action_pressed("attack_a") \
			or event.is_action_pressed("attack_b") \
			or event.is_action_pressed("attack_c") \
			or event.is_action_pressed("jump") \
			or event.is_action_pressed("dash")):
		player.last_input = event
		player.input_timer.start()


func state_process(delta: float) -> void:
	if player.is_aerial_stun:
		state_machine.transition_to("HitstunAir")
		return
	elif player.knockback != Vector2.ZERO:
		state_machine.transition_to("Hitstun")
		return
	
	if player.can_input_cancel:
		if Input.is_action_just_pressed("attack_a") or player.is_input_buffered("attack_a"):
			state_machine.transition_to("AttackA2")
		elif Input.is_action_just_pressed("attack_b") or player.is_input_buffered("attack_b"):
			state_machine.transition_to("AttackB")
		elif Input.is_action_just_pressed("attack_c") or player.is_input_buffered("attack_c"):
			state_machine.transition_to("AttackC")
		elif (Input.is_action_just_pressed("jump") or player.is_input_buffered("jump")):
			state_machine.transition_to("Air", {
				jump = true
			})
		elif Input.is_action_just_pressed("dash") or player.is_input_buffered("dash"):
			state_machine.transition_to("Dash")
		
	if not player.anim.is_playing():
		state_machine.transition_to("Idle")
