class_name Player
extends KinematicBody2D

const JUMP_IMPULSE = 300
const GRAVITY = 700

export var props : Resource

# Movement props
var velocity := Vector2.ZERO
var child_velocity := Vector2.ZERO # Velocity for nested kinematic body

# By default, player should face right
# Used to check if facing left for facing dependant behavior
var is_facing_left := false

# Other
var lane_collisions := []
var last_input : InputEvent
var can_input_cancel := false

onready var anim = $SubBody/AnimationPlayer
onready var player_child = $SubBody
onready var lane_detection = $LaneDetection
onready var input_timer = $InputTimer
onready var ground = $GroundDetection


func _init():
	# Add to players group
	add_to_group("players")


func _ready():
	# Ignore this ground for all players, should only collide with own ground
	get_tree().call_group("players", "add_collision_exception", ground)


func _physics_process(delta):
	lane_collisions = lane_detection.get_overlapping_areas()


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
	velocity.x = props.speed_x * input_vector.x
	velocity.y = props.speed_y * input_vector.y
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


func add_collision_exception(collision):
	# If not own ground collision, ignore collision
	if collision != ground:
		player_child.add_collision_exception_with(collision)
