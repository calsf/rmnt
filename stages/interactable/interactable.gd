class_name Interactable
extends Node

onready var lane_detection = $LaneDetection
onready var interact_label = $InteractableBox/InteractLabel

var lane_collisions := []
var is_interactable := false
var can_interact := true


func _ready():
	show_interact_label(false)


func _physics_process(delta):
	lane_collisions = lane_detection.get_overlapping_areas()


func set_can_interact(interact : bool) -> void:
	can_interact = interact


func on_interactable_box_overlap(player_interact_box : PlayerInteractBox) -> void:
	var player_interact_box_owner = player_interact_box.owner
	
	# Objects must be in same lane for hurtbox/hitbox interaction
	if lane_collisions:
		for area in lane_collisions:
			if area.owner == player_interact_box_owner:
				is_interactable = true
				show_interact_label(true)
				return
		
		# If reaches here, there was no lane collision
		is_interactable = false
		show_interact_label(false)
	else:
		is_interactable = false
		show_interact_label(false)


func show_interact_label(show : bool) -> void:
	if not can_interact: # If cannot interact, always hide interact label
		interact_label.visible = false
	else:
		interact_label.visible = show


func on_interactable_box_exit() -> void:
	is_interactable = false
	show_interact_label(false)
