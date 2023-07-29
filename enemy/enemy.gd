class_name Enemy
extends KinematicBody2D

const JUMP_IMPULSE = 300
const GRAVITY = 700

export var props : Resource

var lane_collisions := []

var knockback := Vector2.ZERO
var knockdown := 0
var is_aerial_stun := false

# Enemy "adaptability" to repeated attacks
# Deals reduced damage on repeat attacks
var attacked_by_max = 5
var dmg_multipliers := [.8, .7, .5, .4, .2] # Corresponding multipliers for [oldest -> most recent]
var attacked_by_hitboxes := [] # Keep track of attacks hit by [oldest -> most recent]

var child_velocity := Vector2.ZERO # Velocity for nested kinematic body
var hit_frame := false # Toggle to switch between hit stun frames

onready var lane_detection = $LaneDetection
onready var enemy_child = $SubBody
onready var ground = $GroundDetection
onready var feet = $SubBody/Feet
onready var anim = $SubBody/AnimationPlayer


func _init():
	# Add to enemies group
	add_to_group("enemies")


func _ready():
	# Ignore this ground for all enemies, should only collide with own ground
	get_tree().call_group("enemies", "add_collision_exception", ground)


func _physics_process(delta):
	lane_collisions = lane_detection.get_overlapping_areas()


# Triggered by EnemyHurtbox
func on_enemy_hurtbox_hit(hitbox_data, hitbox_owner, hitbox) -> bool:
	# Objects must be in same lane for hurtbox/hitbox interaction
	if lane_collisions:
		for area in lane_collisions:
			if area.owner == hitbox_owner:
				print_debug(self.name + "HIT BY PLAYER")
				
				# Find the last attacked by instance which would be most recent instance of the attack
				var attacked_by_index = attacked_by_hitboxes.find_last(hitbox)
				var dmg_multiplier = 1 # Default multiplier
				if attacked_by_index != -1:
					dmg_multiplier = dmg_multipliers[attacked_by_index]
				var hitbox_damage = (hitbox_data["damage"] * dmg_multiplier)
				
				# X and Y hitstun
				var hitbox_knockback_x = (hitbox_data["knockback_x"] * props.hitstun_multiplier)
				var hitbox_knockback_y = (hitbox_data["knockback_y"] * props.hitstun_multiplier)
				var knockback_vector = Vector2(hitbox_knockback_x, hitbox_knockback_y)
				knockback = knockback_vector
				
				# Aerial hitstun
				var hitbox_knockup = (hitbox_data["knockup"] * props.air_hitstun_multiplier)
				var hitbox_knockdown = (hitbox_data["knockdown"] * props.air_hitstun_multiplier)
				if hitbox_knockup > 0:
					child_velocity.y = -hitbox_knockup
					is_aerial_stun = true
				elif hitbox_knockdown > 0 and not enemy_child.is_on_floor():
					knockdown = hitbox_knockdown
					is_aerial_stun = true
				else:
					# If no knockback or knockdown, this is not an 'aerial hitstun' attack
					# Use this to determine whether enemy should fall or stay suspended in air during hit stun
					is_aerial_stun = false
				
				hitstop([self, hitbox_owner])
				toggle_hit_frame()
				
				# Push most recent attack to back
				attacked_by_hitboxes.append(hitbox)
				if attacked_by_hitboxes.size() > attacked_by_max:
					attacked_by_hitboxes.pop_front() # Remove oldest which is at front
				
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


func toggle_hit_frame():
	if hit_frame:
		anim.play("Hit1")
	else:
		anim.play("Hit2")
	hit_frame = not hit_frame


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
