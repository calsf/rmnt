extends PlayerState


func enter(data_state := {}) -> void:
	player.disable_hurtbox()
	player.velocity = Vector2.ZERO
	player.knockback = Vector2.ZERO
	player.knockdown = 0
	player.child_velocity = Vector2.ZERO
	player.is_aerial_stun = false
	
	player.anim.play("Death")


func exit(data_state := {}) -> void:
	return


func state_process(delta: float) -> void:
	return
