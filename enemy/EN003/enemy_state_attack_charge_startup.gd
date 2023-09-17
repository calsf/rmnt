extends EnemyState


func enter(data_state := {}) -> void:
	enemy.anim.play("AttackChargeStartup")
	enemy.is_attacking = true


func exit(data_state := {}) -> void:
	enemy.disable_all_hitboxes()
	enemy.is_attacking = false


func state_physics_process(delta: float) -> void:
	# Face player
	var player = enemy.get_player_target()
	if player.global_position > enemy.global_position:
		enemy.turn(1)
	else:
		enemy.turn(-1)
	
	if not enemy.enemy_child.is_on_floor():
		state_machine.transition_to("HitstunAir")
	elif enemy.is_aerial_stun:
		state_machine.transition_to("HitstunAir")
	elif enemy.knockback != Vector2.ZERO:
		state_machine.transition_to("Hitstun")
	
	if not enemy.anim.is_playing():
		state_machine.transition_to("AttackChargeActive")
