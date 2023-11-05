extends EnemyState

# If escapeable, enemy will escape after being in hitstun for
# a random time from min_stun to max_stun
export var escapeable := false
export var min_stun := 0.01
export var max_stun := 5.00

var stun_time := 0
var escape_time := 0


func enter(data_state := {}) -> void:
	# Reset escape props
	stun_time = OS.get_unix_time()
	escape_time = rand_range(min_stun, max_stun)


func exit(data_state := {}) -> void:
	enemy.is_aerial_stun = false


func state_physics_process(delta: float) -> void:
	var initial_knockback = enemy.knockback
	enemy.knockback = enemy.knockback.move_toward(Vector2.ZERO, enemy.props.ground_decel * delta)
	enemy.knockback = enemy.move_and_slide(enemy.knockback)
	if enemy.get_slide_count():
		enemy.knockback = initial_knockback.bounce(enemy.get_slide_collision(0).normal) # Bounce
	
	if not enemy.is_aerial_stun and enemy.knockback != Vector2.ZERO:
		return
	
	if enemy.knockdown > 0:
		enemy.child_velocity.y = enemy.knockdown
	
	var initial_child_velocity = enemy.child_velocity
	enemy.child_velocity.y += enemy.GRAVITY * delta
	enemy.child_velocity = enemy.enemy_child.move_and_slide(enemy.child_velocity, Vector2.UP)
	if enemy.enemy_child.get_slide_count() and enemy.knockdown > 0:
		enemy.child_velocity = initial_child_velocity.bounce(enemy.enemy_child.get_slide_collision(0).normal) * 0.5
		enemy.knockdown = 0
		return
	
	if enemy.enemy_child.is_on_floor():
		# enemy.enemy_child.position = Vector2.ZERO
		enemy.knockdown = 0
		enemy.is_aerial_stun = false
		state_machine.transition_to("Idle")
	
		# Escape
	if escapeable:
		if abs(stun_time - OS.get_unix_time()) >= escape_time:
			state_machine.transition_to("EscapeFrom")
