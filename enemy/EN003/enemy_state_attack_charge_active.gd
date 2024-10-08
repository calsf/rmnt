extends EnemyState

export var closest_distance := 2.5

var moving_left := false
var moving_down := false

var target_pos := Vector2(0, 0)
var recovering := false


func enter(data_state := {}) -> void:
	enemy.anim.play("AttackChargeActive")
	enemy.is_attacking = true
	
	recovering = false
	moving_left = false
	moving_down = false
	
	# Get initial target position
	var player = enemy.get_player_target()
	target_pos = player.global_position
	enemy.velocity = (target_pos - enemy.global_position).normalized()
	enemy.velocity.x *= enemy.props.speed_x_dash
	enemy.velocity.y *= enemy.props.speed_y_dash
	enemy.turn(enemy.velocity.x)
	
	# Check enemy moving direction
	if enemy.velocity.x > 0:
		moving_left = true
	
	if enemy.velocity.y > 0:
		moving_down = true


func exit(data_state := {}) -> void:
	enemy.disable_all_hitboxes()
	enemy.is_attacking = false
	
	recovering = false
	moving_left = false
	moving_down = false


func state_physics_process(delta: float) -> void:
	# Keeps moving until reaches a screen bound based on the direction enemy is moving
	# Once close to a screen bound, stop moving and enter recovery animation
	if (moving_left and abs(enemy.global_position.x - enemy.max_x) <= closest_distance \
			or not moving_left and abs(enemy.global_position.x - enemy.min_x) <= closest_distance \
			or moving_down and abs(enemy.global_position.y - enemy.min_y) <= closest_distance \
			or not moving_down and abs(enemy.global_position.y - enemy.max_y) <= closest_distance) \
			and not recovering:
		recovering = true
		enemy.anim.play("AttackChargeRecover")
	elif enemy.anim.is_playing() and not recovering:
		enemy.velocity = enemy.move_and_slide(enemy.velocity)
		
	if not enemy.enemy_child.is_on_floor():
		state_machine.transition_to("HitstunAir")
	elif enemy.is_aerial_stun:
		state_machine.transition_to("HitstunAir")
	elif enemy.knockback != Vector2.ZERO:
		state_machine.transition_to("Hitstun")
	
	if not enemy.anim.is_playing():
		state_machine.transition_to("Move")
