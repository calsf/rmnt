extends PlayerState


func enter(data_state := {}) -> void:
	player.velocity = Vector2.ZERO
	player.disable_hurtbox()
	player.anim.play("Spawn")


func exit(data_state := {}) -> void:
	player.enable_hurtbox()


func state_physics_process(delta: float) -> void:
	player.child_velocity.y += player.GRAVITY * delta
	player.child_velocity = player.get_player_child().move_and_slide(player.child_velocity, Vector2.UP)
	
	if not player.anim.is_playing():
		state_machine.transition_to("Idle")
