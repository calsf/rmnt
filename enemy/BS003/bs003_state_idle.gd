# Custom idle for BS003
extends EnemyState

const MIN_IDLE := .6
const MAX_IDLE := 1

var idle_time := 0
var transition_time := 0
var last_ground_slam_time := 0


func enter(data_state := {}) -> void:
	enemy.anim.play("Idle")
	
	# Reset idle timer
	idle_time = OS.get_unix_time()
	transition_time = rand_range(MIN_IDLE, MAX_IDLE)


func exit(data_state := {}) -> void:
	# Disable hitboxes?
	pass


func state_physics_process(delta: float) -> void:
	var player = enemy.get_player_target()
	if player.global_position.x > enemy.global_position.x:
		enemy.turn(1)
	else:
		enemy.turn(-1)
	
	enemy.child_velocity.y += (enemy.GRAVITY / 3) * delta # slower fall than normal
	enemy.child_velocity = enemy.enemy_child.move_and_slide(enemy.child_velocity, Vector2.UP)
	
	if not enemy.enemy_child.is_on_floor():
		state_machine.transition_to("HitstunAir")
	elif enemy.is_aerial_stun:
		state_machine.transition_to("HitstunAir")
	elif enemy.knockback != Vector2.ZERO:
		state_machine.transition_to("Hitstun")
	elif abs(idle_time - OS.get_unix_time()) >= transition_time:
		if not enemy.trigger_states.empty():
			# Check for and trigger a random trigger state
			if enemy.should_trigger_random_state():
				# Trigger waiting state and reset waiting state
				if not enemy.trigger_states.empty() and enemy.waiting_state != null:
					state_machine.transition_to(enemy.waiting_state.trigger_state_name)
					enemy.waiting_state = null
