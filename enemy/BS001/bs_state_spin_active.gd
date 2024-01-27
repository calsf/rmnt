extends EnemyState

export var closest_distance := 2.5

var recovering := false
var active_time := 0.01
var max_active_time := 4.0


func enter(data_state := {}) -> void:
	enemy.anim.play("SpinActive")
	enemy.is_attacking = true
	
	recovering = false
	active_time = OS.get_unix_time()


func exit(data_state := {}) -> void:
	enemy.disable_all_hitboxes()
	enemy.is_attacking = false
	
	recovering = false


func state_physics_process(delta: float) -> void:
	# Move towards player
	if enemy.anim.is_playing() and not recovering:
		if abs(active_time - OS.get_unix_time()) >= max_active_time:
			enemy.anim.play("SpinRecover")
		else:
			var player = enemy.get_player_target()
			if player.global_position.distance_to(enemy.global_position) > closest_distance:
				enemy.velocity = (player.global_position - enemy.global_position).normalized()
				enemy.velocity.x *= enemy.props.speed_x
				enemy.velocity.y *= enemy.props.speed_y
				enemy.velocity = enemy.move_and_slide(enemy.velocity)
				
				# Apply push if stacked on top of another pushbox area
				var push_vector = enemy.pushbox.get_push_vector()
				enemy.global_position += (push_vector * delta) * enemy.props.speed_x
				enemy.turn(enemy.velocity.x)
		
	if not enemy.enemy_child.is_on_floor():
		state_machine.transition_to("HitstunAir")
	elif enemy.is_aerial_stun:
		state_machine.transition_to("HitstunAir")
	elif enemy.knockback != Vector2.ZERO:
		state_machine.transition_to("Hitstun")
	
	if not enemy.anim.is_playing():
		state_machine.transition_to("Move")
