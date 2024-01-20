# Spawn state for dummy to control timing of spawner in anim instead of on enter
extends EnemyState


func enter(data_state := {}) -> void:
	enemy.disable_hurtbox()
	enemy.anim.play("Spawn")


func exit(data_state := {}) -> void:
	# Disable hitboxes?
	enemy.enable_hurtbox()


func state_physics_process(delta: float) -> void:
	if not enemy.anim.is_playing():
		state_machine.transition_to("Idle")
