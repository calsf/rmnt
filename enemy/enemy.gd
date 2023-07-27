class_name Enemy
extends KinematicBody2D

const DECEL = 200

const JUMP_IMPULSE = 300
const GRAVITY = 700

var lane_collisions := []

var knockback := Vector2.ZERO
var knockdown := 0
var is_aerial_stun := false

var child_velocity := Vector2.ZERO # Velocity for nested kinematic body

onready var lane_detection = $LaneDetection
onready var enemy_child = $SubBody
onready var ground = $GroundDetection
onready var feet = $SubBody/Feet


func _init():
	# Add to enemies group
	add_to_group("enemies")


func _ready():
	# Ignore this ground for all enemies, should only collide with own ground
	get_tree().call_group("enemies", "add_collision_exception", ground)


func _physics_process(delta):
	lane_collisions = lane_detection.get_overlapping_areas()


# Triggered by EnemyHurtbox
func on_enemy_hurtbox_hit(hitbox_data, hitbox_owner) -> bool:
	# Objects must be in same lane for hurtbox/hitbox interaction
	if lane_collisions:
		for area in lane_collisions:
			if area.owner == hitbox_owner:
				print_debug(self.name + "HIT BY PLAYER")
				# TEMP HIT STUN BEHAVIOR
				# X and Y hitstun
				var knockback_vector = Vector2(hitbox_data["knockback_x"], hitbox_data["knockback_y"])
				knockback = knockback_vector
				
				# Aerial hitstun
				if hitbox_data["knockup"] > 0:
					child_velocity.y = -hitbox_data["knockup"]
					is_aerial_stun = true
				elif hitbox_data["knockdown"] > 0:
					knockdown = hitbox_data["knockdown"]
					is_aerial_stun = true
				else:
					# If no knockback or knockdown, this is not an 'aerial hitstun' attack
					# Use this to determine whether enemy should fall or stay suspended in air during hit stun
					is_aerial_stun = false
				
				hitstop([self, hitbox_owner])
				
				return true
	return false


func add_collision_exception(collision) -> void:
	# If not own ground collision, ignore collision
	if collision != ground:
		enemy_child.add_collision_exception_with(collision)


func hitstop(objects_hit := [], duration := .05) -> void:
	for obj in objects_hit:
		pause_scene(obj, true)
	yield(get_tree().create_timer(duration), "timeout")
	for obj in objects_hit:
		pause_scene(obj, false)


# Pause specific node and all the children
func pause_scene(node, is_paused):
	pause_node(node, is_paused)
	for child in node.get_children():
		pause_node(child, is_paused)


# Pause specific node
func pause_node(node, is_paused):
	node.set_process(!is_paused)
	node.set_physics_process(!is_paused)
	node.set_process_input(!is_paused)
	node.set_process_internal(!is_paused)
	# node.set_process_unhandled_input(!is_paused)
	# node.set_process_unhandled_key_input(!is_paused)
