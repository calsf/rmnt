extends PlayerState

export var armored := false
export var projectile_path := ""
export var spawn_offset : Vector2

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
	
	if player.is_facing_left:
		proj.global_position = player.global_position + (spawn_offset * Vector2(-1, 1))
		proj.set_dir(Vector2.LEFT)
	else:
		proj.global_position = player.global_position + spawn_offset
		proj.set_dir(Vector2.RIGHT)


func enter(data_state := {}) -> void:
	player.velocity = Vector2.ZERO
	player.anim.play("AttackSpecial")
	player.armored = self.armored
	
	player.knockback = Vector2.ZERO
	player.knockdown = 0
	player.child_velocity = Vector2.ZERO
	player.is_aerial_stun = false
	
	player.disable_hurtbox()


func exit(data_state := {}) -> void:
	player.disable_input_cancel()
	player.disable_all_hitboxes()
	player.armored = false
	
	player.enable_hurtbox()


func handle_input(event: InputEvent) -> void:
	return


func state_process(delta: float) -> void:
	if not player.anim.is_playing():
		state_machine.transition_to("Idle")
