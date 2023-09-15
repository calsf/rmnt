class_name InteractableBox
extends Area2D

# Areas currently overlapping with interact box
var _curr_areas := []


func _init() -> void:
	# Interactable collision layer
	collision_layer = 8192
	
	# Collide with PlayerInteractBox layers
	collision_mask = 4096


func _ready():
	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_on_area_exited")


func _physics_process(delta):
	# Re-trigger area entered behavior as needed
	for area in _curr_areas:
		_on_area_entered(area)


func _on_area_entered(player_interact_box : PlayerInteractBox) -> void:
	if player_interact_box == null:
		return
	
	# Objects may not be in same lane on area entered and may enter lane while still overlapping
	# Keep track of reference to area to keep checking for collision in _physics_process
	if owner.has_method("on_interactable_box_overlap"):
		owner.on_interactable_box_overlap(player_interact_box)
		
		# We want to keep checking area until area exit because we want to check for lane exit
		# This is because you can leave the lane but still be in the area
		if not _curr_areas.has(player_interact_box):
			_curr_areas.append(player_interact_box)


func _on_area_exited(area) -> void:
	if owner.has_method("on_interactable_box_exit"):
		owner.on_interactable_box_exit()
		
	# Also remove reference on area exit
	var area_remove = _curr_areas.find(area)
	if area_remove == -1:
		return
	
	_curr_areas.remove(area_remove)
