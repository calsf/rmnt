# Attack state that moves enemy forward
extends EnemyState

export var projectile_path := ""
export var spawn_offset : Vector2

var is_moving = false

var Projectile


func _ready():
	if projectile_path != null and projectile_path != "":
		Projectile = load(projectile_path)


func spawn_projectile() -> void:
	if not enemy.visible:
		return
	
	var proj = Projectile.instance()
	get_tree().current_scene.get_node("World").add_child(proj)
	
	if enemy.is_facing_left:
		proj.global_position = enemy.global_position + (spawn_offset * Vector2(-1, 1))
		proj.set_dir(Vector2.LEFT)
	else:
		proj.global_position = enemy.global_position + spawn_offset
		proj.set_dir(Vector2.RIGHT)


func enter(data_state := {}) -> void:
	enemy.anim.play("AttackA")
	enemy.is_attacking = true
	
	# If attack is a projectile, face player before spawning projectile
	if projectile_path != null and projectile_path != "":
		var player = enemy.get_player_target()
		if player.global_position.x > enemy.global_position.x:
			enemy.turn(1)
		else:
			enemy.turn(-1)
	
	is_moving = false


func exit(data_state := {}) -> void:
	enemy.disable_all_hitboxes()
	enemy.is_attacking = false


func state_physics_process(delta: float) -> void:
	# Move slowly in facing direction
	if is_moving:
		if enemy.is_facing_left:
			enemy.velocity = Vector2.LEFT
		else:
			enemy.velocity = Vector2.RIGHT

		enemy.velocity.x *= enemy.props.speed_x / 2
		enemy.velocity.y *= 0
		enemy.velocity = enemy.move_and_slide(enemy.velocity)
	
	if not enemy.enemy_child.is_on_floor():
		state_machine.transition_to("HitstunAir")
	elif enemy.is_aerial_stun:
		state_machine.transition_to("HitstunAir")
	elif enemy.knockback != Vector2.ZERO:
		state_machine.transition_to("Hitstun")
	
	if not enemy.anim.is_playing():
		state_machine.transition_to("Idle")


# Used for toggling movement via animation
func set_is_moving(moving : bool) -> void:
	is_moving = moving
