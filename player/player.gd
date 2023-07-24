class_name Player
extends KinematicBody2D

const MAX_SPEED = 175
const RISE_SPEED = 4
const FALL_SPEED = 2.75
const MAX_HEIGHT = 56

# Movement props
var speed_x := 120.0
var speed_y := 100.0
var velocity := Vector2.ZERO

# By default, player should face right
# Used to check if facing left for facing dependant behavior
var is_facing_left := false

# Jump props
var gravity := 0
var jump_height := 0
var is_jumping := false
var is_falling := false
var has_jumped := false
var added_height := 0
var height_change := 0

# Other
var lane_collisions := []
var last_input : InputEvent
var can_input_cancel := false

onready var anim = $SubBody/AnimationPlayer
onready var player_child = $SubBody
onready var lane_detection = $LaneDetection
onready var input_timer = $InputTimer


func _physics_process(delta):
	lane_collisions = lane_detection.get_overlapping_areas()
#	var lane_collisions = lane_detection.get_overlapping_areas()
#	var hitbox_collisions = hitbox.get_overlapping_areas()
#	var hurtbox_collisions = hurtbox.get_overlapping_areas()
#	if lane_collisions and (hitbox_collisions or hurtbox_collisions):
#		# Get the parents of objects in same lane
#		var lane_collision_parents = []
#		for area in lane_collisions:
#			lane_collision_parents.append(area.owner)
#
#		# Process areas that player is hitting and are in the same lane
#		for area in hitbox_collisions:
#			if lane_collision_parents.has(area.owner):
#				print_debug("hit " + area.owner.name)
#
#		# Process areas that are hitting player and are in the same lane
#		for area in hurtbox_collisions:
#			if lane_collision_parents.has(area.owner):
#				print_debug("hurt by " + area.owner.name)
	
	
#	if is_jumping:
#		# Increase added height until reaches jump height
#		# Move player sprite up the same amount
#		if added_height < jump_height:
#			gravity += .025 # Apply increasing rise speed
#			# Avoid jumping above jump height
#			change = min(RISE_SPEED + gravity, jump_height - added_height)
#
#			added_height += change
#			player_child.position.y -= change
#		else:
#			gravity = 0
#			is_falling = true	# Once jump_height is reached, set to falling state
#			is_jumping = false	# No longer in jump state
#	elif is_falling:
#		# Subtract from added height until reaches 0 or less
#		# Move player sprite down the same amount
#		if added_height > 0:
#			gravity += .025	# Apply increasing gravity force
#			change = FALL_SPEED + gravity
#			# Avoid added_height going below 0
#			if added_height - change < 0:
#				change = added_height
#
#			added_height -= change
#			player_child.position.y += change
#		else:
#			# Reset jump related values
#			jump_height = MAX_HEIGHT
#			added_height = 0
#			gravity = 0 	# Reset gravity
#			is_falling = false
#			has_jumped = false


# Triggered by PlayerHurtbox
func on_player_hurtbox_hit(hitbox_data, hitbox_owner) -> bool:
	# Objects must be in same lane for hurtbox/hitbox interaction
	if lane_collisions:
		for area in lane_collisions:
			if area.owner == hitbox_owner:
				print_debug(self.name + "HIT BY ENEMY")
				return true
	return false


# Turn player to face left or right
func turn(facing_x) -> void:
	if facing_x < 0 and scale.y > 0:
		self.scale.y = -1
		self.rotation_degrees = 180
		is_facing_left = true
	elif facing_x > 0 and scale.y < 0:
		self.scale.y = 1
		self.rotation_degrees = 0
		is_facing_left = false


# Disable all hitboxes, should always be called when exiting an attack state
func disable_all_hitboxes() -> void:
	for child in player_child.get_children():
		if child is PlayerHitbox:
			for collision in child.get_children():
				collision.disabled = true


# Return input vector, does not move player
func get_movement_input() -> Vector2:
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector = input_vector.normalized()
	
	return input_vector


# Move player based on input, returns input vector
func update_movement() -> Vector2:
	var input_vector = get_movement_input()
	velocity.x = speed_x * input_vector.x
	velocity.y = speed_y * input_vector.y
	velocity = move_and_slide(velocity)
	turn(velocity.x)
	
	return input_vector


# Check if input has been buffered
# States should set `last_input` and start the input_timer in `handle_input`
# This only allows buffering of ONE last input
# While there is a `last_input` AND timer is counting down, we consider the input buffered and valid
func is_input_buffered(input_name : String) -> bool:
	if last_input == null:
		return false
	
	if last_input.is_action_pressed(input_name) and not input_timer.is_stopped():
		input_timer.stop()
		last_input == null
		return true
	
	return false


# For enabling input cancels, should be enabled during an animation
func enable_input_cancel():
	can_input_cancel = true


# For disabling input cancels, should always be disabled when exiting a state
func disable_input_cancel():
	can_input_cancel = false
