extends EnemyState


func enter(data_state := {}) -> void:
	pass


func exit(data_state := {}) -> void:
	# Disable hitboxes?
	pass


func state_physics_process(delta: float) -> void:
	# TEMP HITSTUN BEHAVIOR
	var initial_knockback = enemy.knockback
	enemy.knockback = enemy.knockback.move_toward(Vector2.ZERO, enemy.DECEL * delta)
	enemy.knockback = enemy.move_and_slide(enemy.knockback)
	if enemy.get_slide_count():
		enemy.knockback = initial_knockback.bounce(enemy.get_slide_collision(0).normal) # Bounce
	
	if enemy.is_jumping:
		# Increase added height until reaches jump height
		# Move player sprite up the same amount
		if enemy.added_height < enemy.jump_height:
			enemy.gravity += .025 # Apply increasing rise speed
			# Avoid jumping above jump height
			enemy.height_change = min(enemy.RISE_SPEED + enemy.gravity, enemy.jump_height - enemy.added_height)

			enemy.added_height += enemy.height_change
			enemy.enemy_child.position.y -= enemy.height_change
		else:
			enemy.gravity = 0
			enemy.is_falling = true	# Once jump_height is reached, set to falling state
			enemy.is_jumping = false	# No longer in jump state
	elif enemy.is_falling:
		# Subtract from added height until reaches 0 or less
		# Move player sprite down the same amount
		if enemy.added_height > 0:
			enemy.gravity += .025	# Apply increasing gravity force
			enemy.height_change = enemy.FALL_SPEED + enemy.gravity
			# Avoid added_height going below 0
			if enemy.added_height - enemy.height_change < 0:
				enemy.height_change = enemy.added_height
			
			# If not aerial stun attack and is in hitstun, keep enemy suspended in air
			if not enemy.is_aerial_stun and enemy.knockback != Vector2.ZERO:
				enemy.height_change = 0
			
			enemy.added_height -= enemy.height_change
			enemy.enemy_child.position.y += enemy.height_change
		else:
			# Reset jump related values
			enemy.jump_height = enemy.MAX_HEIGHT
			enemy.added_height = 0
			enemy.gravity = 0 	# Reset gravity
			enemy.is_falling = false
			enemy.has_jumped = false
