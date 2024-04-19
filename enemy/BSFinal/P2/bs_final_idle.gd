# Custom idle for BSFinal2
extends EnemyState

const MIN_IDLE := 1
const MAX_IDLE := 1

var idle_time := 0
var transition_time := 0

# Name of next attack state to transition to
# If none, transitions to Move
var next_attack := ""


func enter(data_state := {}) -> void:
	enemy.anim.play("Idle")
	
	# Reset idle timer
	idle_time = OS.get_unix_time()
	transition_time = rand_range(MIN_IDLE, MAX_IDLE)
	
	# Only set next_attack again if already empty
	# This is to make sure the next_attack is triggered at least once
	if next_attack == "":
		next_attack = data_state.get("next_attack", "")


func exit(data_state := {}) -> void:
	# Disable hitboxes?
	pass


func state_physics_process(delta: float) -> void:
	if not enemy.enemy_child.is_on_floor():
		state_machine.transition_to("HitstunAir")
	elif enemy.is_aerial_stun:
		state_machine.transition_to("HitstunAir")
	elif enemy.knockback != Vector2.ZERO:
		state_machine.transition_to("Hitstun")
	elif abs(idle_time - OS.get_unix_time()) >= transition_time:
		if not next_attack.empty():
			var attack = next_attack
			next_attack = "" # Reset now that this attack has been triggered
			state_machine.transition_to(attack)
		else:
			state_machine.transition_to("Move")
