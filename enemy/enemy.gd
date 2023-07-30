class_name Enemy
extends KinematicBody2D

const JUMP_IMPULSE = 300
const GRAVITY = 700

export var props : Resource

# Movement props
var velocity := Vector2.ZERO
var child_velocity := Vector2.ZERO # Velocity for nested kinematic body

# By default, enemy should face right
# Used to check if facing left for facing dependant behavior
var is_facing_left := false

var lane_collisions := []

var knockback := Vector2.ZERO
var knockdown := 0
var is_aerial_stun := false

# Enemy "adaptability" to repeated attacks
# Deals reduced damage on repeat attacks
var attacked_by_max = 5
var dmg_multipliers := [.8, .7, .5, .4, .2] # Corresponding multipliers for [oldest -> most recent]
var attacked_by_hitboxes := [] # Keep track of attacks hit by [oldest -> most recent]

var hit_frame := false # Toggle to switch between hit stun frames

# Set of Dictionary objects from EnemyRangebox, each entry contains trigger state info
# Trigger states are states that enemy can transition to
# Only one Dictionary object should exist for each unique trigger state name
var trigger_states := []

# The trigger state currently waiting to trigger
# When a trigger state is selected to trigger, delay trigger by some time based on the trigger state info
# Should be cleared upon state trigger or when it is removed from set of trigger_states
var waiting_state = null

onready var lane_detection = $LaneDetection
onready var enemy_child = $SubBody
onready var ground = $GroundDetection
onready var feet = $SubBody/Feet
onready var anim = $SubBody/AnimationPlayer
onready var pushbox = $Pushbox
onready var delay_timer = $DelayTimer
onready var players = get_tree().get_nodes_in_group("players")


func _init():
	# Add to enemies group
	add_to_group("enemies")


func _ready():
	# Ignore this ground for all enemies, should only collide with own ground
	get_tree().call_group("enemies", "add_collision_exception", ground)
	disable_all_hitboxes()


func _physics_process(delta):
	lane_collisions = lane_detection.get_overlapping_areas()


# Triggered by EnemyHurtbox
func on_enemy_hurtbox_hit(hitbox : PlayerHitbox) -> bool:
	var hitbox_data = hitbox.get_data_state()
	var hitbox_owner = hitbox.owner
		
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


func on_enemy_rangebox_hit(other_rangebox : PlayerRangebox, enemy_rangebox : EnemyRangebox) -> bool:
	var other_rangebox_owner = other_rangebox.owner
	
	# Objects must be in same lane for hurtbox/hitbox interaction
	if lane_collisions:
		for area in lane_collisions:
			if area.owner == other_rangebox_owner:
				# Avoid duplicate trigger states
				if find_trigger_state(enemy_rangebox.trigger_state_name) == -1:
					trigger_states.append({
							"trigger_state_name": enemy_rangebox.trigger_state_name,
							"trigger_min_delay": enemy_rangebox.trigger_min_delay,
							"trigger_max_delay": enemy_rangebox.trigger_max_delay
						})
					return true
	return false


# Turn enemy to face left or right
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
	for child in enemy_child.get_children():
		if child is EnemyHitbox:
			for collision in child.get_children():
				collision.disabled = true


# Checks for timer and if is waiting on a state
# Returns true if state should be triggered
# Returns false if is waiting
# Set random trigger state if no waiting state/no state to be triggered
func should_trigger_random_state() -> bool:
	if delay_timer.is_stopped():
		if waiting_state == null:
			# Timer is stopped and not waiting for a state to trigger
			set_random_trigger_state()
			return false
		else:
			# Timer is stopped and is waiting on a state, trigger state
			return true
	else:
		# If waiting state was cleared, stop timer
		if waiting_state == null:
			delay_timer.stop()
		
		# Do not trigger state
		return false


# Get and set a random trigger state to wait for and start timer to wait
func set_random_trigger_state():
	randomize()
	var random_state = randi() % trigger_states.size()
	waiting_state = trigger_states[random_state]
	
	randomize()
	var wait = rand_range(waiting_state.trigger_min_delay, waiting_state.trigger_max_delay)
	
	delay_timer.start(wait)


# Removes trigger state and clears waiting state if trigger state was removed
func remove_trigger_state(trigger_state : String) -> void:
	var state_index = find_trigger_state(trigger_state)
	if state_index != -1:
		# Clear waiting state if trigger state is being removed
		if waiting_state != null \
				and waiting_state.trigger_state_name == trigger_state:
			waiting_state = null
		trigger_states.remove(state_index)


# Find Dictionary entry in trigger_states for the given trigger state name
# Returns the index of the entry, -1 if not found
func find_trigger_state(trigger_state : String) -> int:
	for i in range(0, trigger_states.size()):
		if trigger_states[i].trigger_state_name == trigger_state:
			return i
	
	# Not found
	return -1


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
