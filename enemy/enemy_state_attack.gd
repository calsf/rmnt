extends EnemyState

export var projectile_path := ""
export var spawn_offset : Vector2
export var anim_name := ""

var Projectile


func _ready():
	if projectile_path != null and projectile_path != "":
		Projectile = load(projectile_path)


func spawn_projectile(y_dir := 0) -> void:
	if not enemy.visible:
		return
	
	var proj = Projectile.instance()
	get_tree().current_scene.get_node("World").add_child(proj)
	
	# Spawn offset on the projectile scene root node should always offset by x only
	# Need to apply y offset on the projectile child sprite based on player child body
	var spawn_offset_y = Vector2(0, enemy.enemy_child.position.y)
	
	if enemy.is_facing_left:
		proj.global_position = enemy.global_position + (spawn_offset * Vector2(-1, 1))
		proj.set_offset_y(spawn_offset_y)
		proj.set_dir(Vector2(-1, y_dir).normalized())
	else:
		proj.global_position = enemy.global_position + spawn_offset
		proj.set_offset_y(spawn_offset_y)
		proj.set_dir(Vector2(1, y_dir).normalized())


# Spawns projectile at player position
func spawn_projectile_on_player() -> void:
	if not enemy.visible:
		return
	
	var proj = Projectile.instance()
	get_tree().current_scene.get_node("World").add_child(proj)
	
	var player = enemy.get_player_target()
	proj.global_position = player.global_position


# Spawns projectile at position
func spawn_projectile_at_pos(pos : Vector2) -> void:
	if not enemy.visible:
		return
	
	var proj = Projectile.instance()
	get_tree().current_scene.get_node("World").add_child(proj)
	
	if enemy.is_facing_left:
		proj.global_position = pos
		proj.set_dir(Vector2(-1, 0).normalized())
	else:
		proj.global_position = pos
		proj.set_dir(Vector2(1, 0).normalized())


# Spawns projectile at random pos
func spawn_projectile_at_random_pos() -> void:
	if not enemy.visible:
		return
	
	var proj = Projectile.instance()
	get_tree().current_scene.get_node("World").add_child(proj)
	
	var random_pos_x = rand_range(enemy.min_x, enemy.max_x)
	var random_pos_y = rand_range(enemy.max_y, enemy.min_y) # "Up" or max_y is lower number
	var pos = Vector2(random_pos_x, random_pos_y)
	
	if enemy.is_facing_left:
		proj.global_position = pos
		proj.set_dir(Vector2(-1, 0).normalized())
	else:
		proj.global_position = pos
		proj.set_dir(Vector2(1, 0).normalized())


# Extra method to shake stage during attack animations if needed
func shake_stage() -> void:
	var stage = get_tree().current_scene
	stage.shake()


func enter(data_state := {}) -> void:
	enemy.anim.play(anim_name)
	enemy.is_attacking = true
	
	# If attack is a projectile, face player before spawning projectile
	if projectile_path != null and projectile_path != "":
		var player = enemy.get_player_target()
		if player.global_position.x > enemy.global_position.x:
			enemy.turn(1)
		else:
			enemy.turn(-1)


func exit(data_state := {}) -> void:
	enemy.disable_all_hitboxes()
	enemy.is_attacking = false


func state_physics_process(delta: float) -> void:	
	if enemy.is_aerial_stun:
		state_machine.transition_to("HitstunAir")
	elif enemy.knockback != Vector2.ZERO:
		state_machine.transition_to("Hitstun")
	
	if not enemy.anim.is_playing():
		state_machine.transition_to("Idle")
