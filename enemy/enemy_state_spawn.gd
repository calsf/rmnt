extends EnemyState


func enter(data_state := {}) -> void:
	### TEMP??
	#yield(owner.get_parent().get_parent(), "ready")
	
	enemy.disable_hurtbox()
	enemy.anim.play("Spawn")
	enemy.activate_spawner()


func exit(data_state := {}) -> void:
	# Disable hitboxes?
	enemy.enable_hurtbox()


func state_physics_process(delta: float) -> void:
	if not enemy.anim.is_playing():
		state_machine.transition_to("Idle")

