extends PlayerState

export var armored := false
export var projectile_path := ""
export var spawn_offset : Vector2
export var is_falling_attack := false

export var dash_speed : float
export var is_dashing_attack := false

var moving_dir := 0
var has_landed := false
var Projectile


func _ready():
	if projectile_path != null and projectile_path != "":
		Projectile = load(projectile_path)


func spawn_projectile() -> void:
	if not player.visible:
		return
	
	var proj = Projectile.instance()
	get_tree().current_scene.get_node("World").add_child(proj)
	proj.projectile_hitbox.player_owner = player
	
	# Spawn offset on the projectile scene root node should always offset by x only
	# Need to apply y offset on the projectile child sprite based on player child body
	var spawn_offset_y = Vector2(0, player.get_player_child().position.y)
	
	if player.is_facing_left:
		proj.global_position = player.global_position + (spawn_offset * Vector2(-1, 1))
		proj.set_offset_y(spawn_offset_y)
		proj.set_dir(Vector2.LEFT)
	else:
		proj.global_position = player.global_position + spawn_offset
		proj.set_offset_y(spawn_offset_y)
		proj.set_dir(Vector2.RIGHT)


func enter(data_state := {}) -> void:
	# Spend all meter
	player.lose_meter(player.props.max_meter)
	
	player.velocity = Vector2.ZERO
	player.anim.play("AttackSpecial")
	player.armored = self.armored
	
	player.knockback = Vector2.ZERO
	player.knockdown = 0
	player.child_velocity = Vector2.ZERO
	player.is_aerial_stun = false
	
	player.disable_hurtbox()
	
	# Set x movement direction based only initial input
	if Input.is_action_pressed("move_left"):
		moving_dir = -1
	elif Input.is_action_pressed("move_right"):
		moving_dir = 1
	else:
		moving_dir = 0
	
	# If is a dashing attack, should use facing direction for moving_dir
	if is_dashing_attack:
		if player.is_facing_left:
			moving_dir = -1
		else:
			moving_dir = 1
	
	has_landed = false


func exit(data_state := {}) -> void:
	player.disable_input_cancel()
	player.disable_all_hitboxes()
	player.armored = false
	
	player.enable_hurtbox()
	moving_dir = 0
	has_landed = false


func handle_input(event: InputEvent) -> void:
	return


func state_process(delta: float) -> void:
	if not player.anim.is_playing():
		state_machine.transition_to("Idle")


func state_physics_process(delta: float) -> void:
	if not has_landed and player.get_player_child().is_on_floor():
		has_landed = true
	
	if is_falling_attack:
		# Maintain x velocity from initial input while in air
		# If is dashing attack, also keeps x velocity while grounded
		if not has_landed:
			if is_dashing_attack:
				player.velocity.x = dash_speed * moving_dir
				player.velocity = player.move_and_slide(player.velocity)
			else:
				player.velocity.x = player.props.speed_x * moving_dir
				player.velocity = player.move_and_slide(player.velocity)
		elif is_dashing_attack:
			player.velocity.x = dash_speed * moving_dir
			player.velocity = player.move_and_slide(player.velocity)
	
		player.child_velocity.y += player.GRAVITY * delta
		player.child_velocity = player.get_player_child().move_and_slide(player.child_velocity, Vector2.UP)
