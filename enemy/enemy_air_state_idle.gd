extends EnemyState


func enter(data_state := {}) -> void:
	enemy.anim.play("Idle")


func exit(data_state := {}) -> void:
	# Disable hitboxes?
	pass


func state_physics_process(delta: float) -> void:
	if enemy.is_aerial_stun or enemy.knockback != Vector2.ZERO:
		state_machine.transition_to("Hitstun")
	else:
		state_machine.transition_to("Move")
