# Checks for stacking and push away from eachother
extends Area2D


func _init() -> void:
	# EnemyPushbox layer
	collision_layer = 2048
	
	# Collide with EnemyPushbox layers
	collision_mask = 2048


# Responsible for flock-like behavior based on overlapping pushbox
# Check if any pushbox area is overlapping, return Vector2 to push away from eachother
func get_push_vector() -> Vector2:
	var areas = get_overlapping_areas()
	if areas:
		return (global_position - areas[0].global_position).normalized()
	else:
		return Vector2.ZERO
