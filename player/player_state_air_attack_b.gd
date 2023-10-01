extends PlayerState

export var armored := false
export var projectile_path := ""
export var spawn_offset : Vector2

var Projectile


func _ready():
	if projectile_path != null and projectile_path != "":
		Projectile = load(projectile_path)


# If face left is not specified, default to player facing direction
func spawn_projectile(face_left = null) -> void:
	var proj = Projectile.instance()
	get_tree().current_scene.get_node("World").add_child(proj)
	
	# Spawn offset on the projectile scene root node should always offset by x only
	# Need to apply y offset on the projectile child sprite based on player child body
	var spawn_offset_y = Vector2(0, player.player_child.position.y)
	
	if face_left or (face_left == null and player.is_facing_left):
		proj.global_position = player.global_position + (spawn_offset * Vector2(-1, 1))
		proj.set_offset_y(spawn_offset_y)
		proj.set_dir(Vector2.LEFT)
	else:
		proj.global_position = player.global_position + spawn_offset
		proj.set_offset_y(spawn_offset_y)
		proj.set_dir(Vector2.RIGHT)


func enter(data_state := {}) -> void:
	player.anim.play("AirAttackB")
	player.armored = self.armored


func exit(data_state := {}) -> void:
	player.disable_input_cancel()
	player.disable_all_hitboxes()
	player.armored = false


func handle_input(event: InputEvent) -> void:
	# Bufferable inputs
	if (event.is_action_pressed("attack_a") \
			or event.is_action_pressed("attack_b") \
			or event.is_action_pressed("attack_c") \
			or event.is_action_pressed("jump") \
			or event.is_action_pressed("dash")):
		player.last_input = event
		player.input_timer.start()


func state_physics_process(delta: float) -> void:
	if player.is_aerial_stun:
		state_machine.transition_to("HitstunAir")
		return
	elif player.knockback != Vector2.ZERO:
		state_machine.transition_to("Hitstun")
		return
	
	# Do not allow turning during air attack
	player.update_movement(false)
	
	player.child_velocity.y += player.GRAVITY * delta
	player.child_velocity = player.player_child.move_and_slide(player.child_velocity, Vector2.UP)
	
	if player.player_child.is_on_floor():
		if Input.is_action_just_pressed("attack_a"):
			state_machine.transition_to("AttackA1")
		elif Input.is_action_just_pressed("attack_b"):
			state_machine.transition_to("AttackB")
		elif Input.is_action_just_pressed("attack_c"):
			state_machine.transition_to("AttackC")
		elif (Input.is_action_just_pressed("jump") or player.is_input_buffered("jump")):
			state_machine.transition_to("Air", {
				jump = true
			})
		elif Input.is_action_just_pressed("dash") or player.is_input_buffered("dash"):
			state_machine.transition_to("Dash")
		else:
			state_machine.transition_to("Idle")

	if player.can_input_cancel:
		if Input.is_action_just_pressed("attack_a") or player.is_input_buffered("attack_a"):
			state_machine.transition_to("AirAttackA")
		elif Input.is_action_just_pressed("attack_c") or player.is_input_buffered("attack_c"):
			state_machine.transition_to("AirAttackC")
		elif Input.is_action_just_pressed("dash") or player.is_input_buffered("dash"):
			state_machine.transition_to("Dash")
	
	if not player.anim.is_playing():
		state_machine.transition_to("Air")
