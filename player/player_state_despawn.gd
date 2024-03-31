extends PlayerState

var despawning := false
var in_prev_anim := true


func enter(data_state := {}) -> void:
	player.disable_hurtbox()
	player.knockback = Vector2.ZERO
	player.knockdown = 0
	player.is_aerial_stun = false
	
	despawning = false
	in_prev_anim = true
	
	# Instant despawn or wait for prev animation
	var instant_despawn = data_state.get("instant_despawn", false)
	if not instant_despawn:
		yield(player.anim, "animation_finished")
	in_prev_anim = false
	
	# Delay
	var delay = data_state.get("delay", .5)
	yield(get_tree().create_timer(delay, false), "timeout")
	despawning = true
	player.anim.play("Despawn")
	
	if player.visible:
		SoundsGlobal.play("RmntDespawn")


func exit(data_state := {}) -> void:
	return


func state_physics_process(delta: float) -> void:
	player.child_velocity.y += player.GRAVITY * delta
	player.child_velocity = player.get_player_child().move_and_slide(player.child_velocity, Vector2.UP)
	
	if not in_prev_anim and not despawning:
		if not player.get_player_child().is_on_floor():
			player.anim.play("AirIdle")
		else:
			player.anim.play("Idle")
	
	if despawning and not player.anim.is_playing():
		player.deactivate()
