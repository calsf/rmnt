extends EnemyState

# If escapeable, enemy will escape after being in hitstun for
# a random time from min_stun to max_stun
export var escapeable := false
export var min_stun := 0.01
export var max_stun := 5.00

var stun_time := 0
var escape_time := 0


func enter(data_state := {}) -> void:
	enemy.child_velocity.y = 0
	
	# Reset escape props
	stun_time = OS.get_unix_time()
	escape_time = rand_range(min_stun, max_stun)


func exit(data_state := {}) -> void:
	# Disable hitboxes?
	pass


func state_physics_process(delta: float) -> void:
	if enemy.is_aerial_stun:
			state_machine.transition_to("HitstunAir")
	
	var initial_knockback = enemy.knockback
	enemy.knockback = enemy.knockback.move_toward(Vector2.ZERO, enemy.props.ground_decel * delta)
	enemy.knockback = enemy.move_and_slide(enemy.knockback)
	if enemy.get_slide_count():
		enemy.knockback = initial_knockback.bounce(enemy.get_slide_collision(0).normal) # Bounce
	
	if enemy.knockback == Vector2.ZERO:
		state_machine.transition_to("Idle")
	
	# Escape
	if escapeable:
		if abs(stun_time - OS.get_unix_time()) >= escape_time:
			state_machine.transition_to("EscapeFrom")
