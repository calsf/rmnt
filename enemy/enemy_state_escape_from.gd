extends EnemyState


func enter(data_state := {}) -> void:
	enemy.disable_hurtbox()
	enemy.disable_all_hitboxes()
	enemy.anim.play("EscapeFrom")


func exit(data_state := {}) -> void:
	pass


func state_physics_process(delta: float) -> void:
	if not enemy.anim.is_playing():
		state_machine.transition_to("EscapeTo")

