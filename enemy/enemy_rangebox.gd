class_name EnemyRangebox
extends Area2D

# The state name to trigger upon entering this rangebox
export var trigger_state_name : String

# The time range for delaying transitioning to the trigger state name
export var trigger_min_delay := 0.05
export var trigger_max_delay := 0.05

# Ignore lane collision for this rangebox, false by default
# Only use is for when the rangebox is entire screen (always in range)
# Collision object(s) ARE NOT needed if this is true and will be removed if added
export var ignore_lane_collision := false

# Areas currently overlapping with hurtbox
var _curr_areas := []


func _init() -> void:
	# No collision layer
	collision_layer = 0
	
	# Collide with PlayerRangebox layers
	collision_mask = 1024


func _ready():
	# If ignoring lane collision, we can assume always in range
	if ignore_lane_collision:
		# Remove any collision objects
		for collision in get_children():
			collision.queue_free()
		
		# Add this rangebox to owner enemy trigger states
		# The trigger state will never get removed
		# since _on_area_exited will never be triggered for this area
		if owner.has_method("add_trigger_state"):
			owner.add_trigger_state(self)
	
	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_on_area_exited")


func _physics_process(delta):
	# Re-trigger area entered behavior as needed
	for area in _curr_areas:
		_on_area_entered(area)


func _on_area_entered(player_rangebox : PlayerRangebox) -> void:
	if player_rangebox == null or not is_instance_valid(player_rangebox):
		return
	
	# Objects may not be in same lane on area entered and may enter lane while still overlapping
	# Keep track of reference to area to keep checking for collision in _physics_process
	# If hit, remove the reference to stop checking
	if is_instance_valid(owner) and owner.has_method("on_enemy_rangebox_hit"):
		if owner.on_enemy_rangebox_hit(player_rangebox, self):
			# Do not remove trigger state from enemy's set of trigger states until area is exited
			return
		elif not _curr_areas.has(player_rangebox):
			_curr_areas.append(player_rangebox)


func _on_area_exited(area) -> void:
	# Also remove reference on area exit
	if owner.has_method("remove_trigger_state"):
		owner.remove_trigger_state(trigger_state_name)
	var area_remove = _curr_areas.find(area)
	if area_remove == -1:
		return
	
	_curr_areas.remove(area_remove)
