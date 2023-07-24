class_name Enemy
extends KinematicBody2D

const DECEL = 200

const MAX_SPEED = 175
const RISE_SPEED = 3.5
const FALL_SPEED = 3
const MAX_HEIGHT = 48

var lane_collisions := []

var knockback = Vector2.ZERO

# Jump props
var gravity := 0
var jump_height := 0
var is_jumping := false
var is_falling := false
var has_jumped := false
var added_height := 0
var height_change := 0
var is_aerial_stun := false

onready var lane_detection = $LaneDetection
onready var enemy_child = $SubBody


func _ready():
	pass


func _physics_process(delta):
	lane_collisions = lane_detection.get_overlapping_areas()
	
	# TEMP HITSTUN BEHAVIOR
#	knockback = knockback.move_toward(Vector2.ZERO, DECEL * delta)
#	curr_knockback_strength = clamp(curr_knockback_strength - (DECEL * delta), 0, 9999)
#	knockback = move_and_slide(knockback)
#
#	if is_jumping:
#		# Increase added height until reaches jump height
#		# Move player sprite up the same amount
#		if added_height < jump_height:
#			gravity += .025 # Apply increasing rise speed
#			# Avoid jumping above jump height
#			height_change = min(RISE_SPEED + gravity, jump_height - added_height)
#
#			added_height += height_change
#			enemy_child.position.y -= height_change
#		else:
#			gravity = 0
#			is_falling = true	# Once jump_height is reached, set to falling state
#			is_jumping = false	# No longer in jump state
#	elif is_falling:
#		# Subtract from added height until reaches 0 or less
#		# Move player sprite down the same amount
#		if added_height > 0:
#			gravity += .025	# Apply increasing gravity force
#			height_change = FALL_SPEED + gravity
#			# Avoid added_height going below 0
#			if added_height - height_change < 0:
#				height_change = added_height
#
#			# If not aerial stun attack and is in hitstun, keep enemy suspended in air
#			if not is_aerial_stun and knockback != Vector2.ZERO:
#				height_change = 0
#
#			added_height -= height_change
#			enemy_child.position.y += height_change
#		else:
#			# Reset jump related values
#			jump_height = MAX_HEIGHT
#			added_height = 0
#			gravity = 0 	# Reset gravity
#			is_falling = false
#			has_jumped = false


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
					jump_height = hitbox_data["knockup"]
					gravity = 0
					has_jumped = true
					is_jumping = true
					is_falling = false
					is_aerial_stun = true
				elif hitbox_data["knockdown"] > 0:
					gravity = hitbox_data["knockdown"]
					is_jumping = false
					is_falling = true
					is_aerial_stun = true
				else:
					# If no knockback or knockdown, this is not an 'aerial hitstun' attack
					# Use this to determine whether enemy should fall or stay suspended in air during hit stun
					is_aerial_stun = false
				
				return true
	return false
