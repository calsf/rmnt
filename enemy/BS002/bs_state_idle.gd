# Custom idle for BS002
extends EnemyState

const MIN_IDLE := 1
const MAX_IDLE := 1.5

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
	if not enemy.enemy_child.is_on_floor():
		state_machine.transition_to("HitstunAir")
	elif enemy.is_aerial_stun:
		state_machine.transition_to("HitstunAir")
	elif enemy.knockback != Vector2.ZERO:
		state_machine.transition_to("Hitstun")
	elif abs(idle_time - OS.get_unix_time()) >= transition_time:
		# Transition to GroundSlam attack if certain amount of time has passed
		# since last GroundSlam attack
		if abs(last_ground_slam_time - OS.get_unix_time()) >= 6:
			last_ground_slam_time = OS.get_unix_time()
			state_machine.transition_to("GroundSlam")
		else:
			state_machine.transition_to("Move")
