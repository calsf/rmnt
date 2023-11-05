extends EnemyState

export var escape_dist_x := 0


func enter(data_state := {}) -> void:
	enemy.anim.play("EscapeTo")
	
	# Escape to opposite side of facing direction
	# If doing so will go past bounds, escape in other direction
	var x = 0
	if enemy.is_facing_left:
		x = enemy.global_position.x + escape_dist_x
		if x > enemy.max_x:
			x = enemy.global_position.x - escape_dist_x
	else:
		x = enemy.global_position.x - escape_dist_x
		if x < enemy.min_x:
			x = enemy.global_position.x + escape_dist_x
	
	enemy.global_position = Vector2(x, enemy.global_position.y)
		


func exit(data_state := {}) -> void:
	# Re-enable hurtbox and reset hitstun related values
	enemy.enable_hurtbox()
	enemy.knockback = Vector2.ZERO
	enemy.knockdown = 0
	enemy.child_velocity = Vector2.ZERO
	enemy.is_aerial_stun = false


func state_physics_process(delta: float) -> void:
	if not enemy.anim.is_playing():
		state_machine.transition_to("Idle")
