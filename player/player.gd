class_name Player
extends KinematicBody2D

const JUMP_IMPULSE = 300
const GRAVITY = 700

export var props : Resource
var curr_hp : float
var curr_meter : float

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

var armored := false
var knockback := Vector2.ZERO
var knockdown := 0
var is_aerial_stun := false

var hit_frame := false # Toggle to switch between hit stun frames

onready var anim = $SubBody/AnimationPlayer
onready var player_child = $SubBody
onready var shake_anim = $SubBody/ShakeAnim
onready var lane_detection = $LaneDetection
onready var input_timer = $InputTimer
onready var dash_timer = $DashTimer
onready var ground = $GroundDetection
onready var hurtbox = $SubBody/PlayerHurtbox
onready var state_machine = $States

signal health_updated()
signal died()
signal meter_gained()


func _init():
	# Add to players group
	add_to_group("players")


func _ready():
	# Ignore this ground for all players, should only collide with own ground
	get_tree().call_group("players", "add_collision_exception", ground)
	disable_all_hitboxes()
	
	# Init
	props = props as PlayerProps
	curr_hp = props.max_hp
	curr_meter = 0.0


func _physics_process(delta):
	lane_collisions = lane_detection.get_overlapping_areas()


# Connect and initialize hud for this player
# To be called by stage when activating the active player
func init_hud():
	# Connect hud signals if applicable
	if get_tree().current_scene.has_node("HUD"):
		var hud = get_tree().current_scene.get_node("HUD")
		hud.init_player_bar(self)
	
	curr_hp = props.max_hp
	curr_meter = 0.0
	emit_signal("health_updated", self)
	emit_signal("meter_gained", self)


# For main stage, sets player bar to display current player info
# Requires all players to have init and connected signals to hud
func set_as_player_bar():
	if get_tree().current_scene.has_node("HUD"):
		var hud = get_tree().current_scene.get_node("HUD")
		hud.set_as_player_bar(self)
	
	emit_signal("health_updated", self)
	emit_signal("meter_gained", self)


func take_damage(dmg : float) -> void:
	curr_hp -= dmg
	
	# Death check
	if curr_hp <= 0:
		curr_hp = 0
		emit_signal("died", self)
		
		# Force transition to death state
		state_machine.transition_to("Death")
	else:
		activate_hitsparks()
	
	emit_signal("health_updated", self)


func activate_hitsparks() -> void:
	var hitsparks = load(props.hitsparks_path).instance()
	hitsparks.global_position = player_child.global_position
	get_tree().current_scene.get_node("World").add_child(hitsparks)


func gain_health(health : float) -> void:
	curr_hp = min(curr_hp + health, props.max_hp)
	
	emit_signal("health_updated", self)


func gain_meter(meter_gain : float) -> void:
	curr_meter += meter_gain
	if curr_meter > props.max_meter:
		curr_meter = props.max_meter
	
	emit_signal("meter_gained", self)


func lose_meter(meter_loss : float) -> void:
	curr_meter = min(curr_meter - meter_loss, 0)
	
	emit_signal("meter_gained", self)


# Triggered by PlayerHurtbox
func on_player_hurtbox_hit(hitbox : EnemyHitbox) -> bool:
	# Ignore if dead
	if curr_hp <= 0:
		return false
	
	var hitbox_data = hitbox.get_data_state()
	var hitbox_owner = hitbox.owner
	
	# Objects must be in same lane for hurtbox/hitbox interaction
	if lane_collisions:
		for area in lane_collisions:
			if is_instance_valid(area) and area.owner == hitbox_owner:
				if hitbox_owner is Projectile and hitbox_owner.destroy_on_hit:
					print_debug(self.name + "HIT BY PROJECTILE")
					hitbox_owner.destroy()
				
				print_debug(self.name + "HIT BY PLAYER")
				
				var hitbox_damage = hitbox_data["damage"]
				
				if not armored: # Not armored
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
					elif hitbox_knockdown > 0 and not player_child.is_on_floor():
						knockdown = hitbox_knockdown
						is_aerial_stun = true
					else:
						# If no knockback or knockdown, this is not an 'aerial hitstun' attack
						# Use this to determine whether enemy should fall or stay suspended in air during hit stun
						is_aerial_stun = false
					
					toggle_hit_frame()
					take_damage(hitbox_damage)
				else: # Armored
					hitbox_damage = hitbox_damage / 2
					take_damage(hitbox_damage)
				
				Global.hitstop([self, hitbox_owner])
				
				shake_anim.play("Shake")
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
				collision.call_deferred("set_disabled", true)


func disable_hurtbox() -> void:
	for collision in hurtbox.get_children():
		collision.call_deferred("set_disabled", true)


func enable_hurtbox() -> void:
	for collision in hurtbox.get_children():
		collision.call_deferred("set_disabled", false)


# Return input vector, does not move player
func get_movement_input() -> Vector2:
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector = input_vector.normalized()
	
	return input_vector


# Move player based on input, returns input vector
func update_movement(can_turn := true) -> Vector2:
	var input_vector = get_movement_input()
	velocity.x = props.speed_x * input_vector.x
	velocity.y = props.speed_y * input_vector.y
	velocity = move_and_slide(velocity)
	
	if can_turn:
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


func toggle_hit_frame():
	if hit_frame:
		anim.play("Hit1")
	else:
		anim.play("Hit2")
	hit_frame = not hit_frame


# Reset state and pause player
func pause_player(is_paused):
	state_machine.transition_to("Idle")
	Global.pause_scene(self, is_paused)


# Reset state and display player
# Can set position to activate at
func activate(position = null):
	if state_machine:
		last_input = null
		state_machine.transition_to(state_machine.initial_state_name)
	
	visible = true
	
	yield(get_tree(), "idle_frame")
	if position != null:
		global_position = position


# Reset state and hide player, also moves player to off screen area since state machine is still active
func deactivate():
	# Keep far away to avoid entering any large enemy rangeboxes from offscreen
	global_position = Vector2(-1000, 120)
	visible = false
	
	if state_machine:
		last_input = null
		state_machine.transition_to(state_machine.initial_state_name)


func get_player_child():
	if player_child == null:
		player_child = $SubBody
	
	return player_child
