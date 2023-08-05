extends PlayerState

export var dash_speed : float
export var anim_name : String

var initial_dash_vector : Vector2
var movement_enabled := false


func enter(data_state := {}) -> void:
	player.velocity = Vector2.ZERO
	player.anim.play(anim_name)
	
	movement_enabled = false
	
	if player.is_facing_left:
		initial_dash_vector = Vector2.LEFT
	else:
		initial_dash_vector = Vector2.RIGHT


func exit(data_state := {}) -> void:
	player.disable_input_cancel()
	player.disable_all_hitboxes()


func handle_input(event: InputEvent) -> void:
	# Bufferable inputs
	if (event.is_action_pressed("attack_a") \
			or event.is_action_pressed("attack_b")
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
	
	if movement_enabled:
		player.velocity.x = dash_speed * initial_dash_vector.x
		player.velocity.y = 0
		player.velocity = player.move_and_slide(player.velocity)
	
	if player.can_input_cancel: # Do not allow cancel into same attack
		if Input.is_action_just_pressed("attack_a") or player.is_input_buffered("attack_a"):
			if self.name != "AttackA1":
				state_machine.transition_to("AttackA1")
		elif Input.is_action_just_pressed("attack_b") or player.is_input_buffered("attack_b"):
			if self.name != "AttackB":
				state_machine.transition_to("AttackB")
		elif Input.is_action_just_pressed("attack_c") or player.is_input_buffered("attack_c"):
			if self.name != "AttackC":
				state_machine.transition_to("AttackC")
		elif (Input.is_action_just_pressed("jump") or player.is_input_buffered("jump")):
			state_machine.transition_to("Air", {
				jump = true
			})
		elif Input.is_action_just_pressed("dash") or player.is_input_buffered("dash"):
			state_machine.transition_to("Dash")
		
	if not player.anim.is_playing():
		state_machine.transition_to("Idle")


# To enable and disable movement from animation
func enable_movement():
	movement_enabled = true


func disable_movement():
	movement_enabled = false
