class_name PlayerHitbox
extends Area2D

export var disabled_on_start := true
export var damage := 0.0
export var knockback_x := 0.0
export var knockback_y := 0.0
export var knockup := 0.0
export var knockdown := 0.0


func _init():
	# PlayerHitbox layer
	collision_layer = 4
	
	# Collide with nothing
	collision_mask = 0


func _ready():
	# Disable or enable hitbox collision shapes on initial load
	for collision in get_children():
		collision.disabled = disabled_on_start


func get_data_state() -> Dictionary:
	var x = knockback_x
	if owner.is_facing_left:
		x *= -1
	
	return {
		"damage": damage,
		"knockback_x": x,
		"knockback_y": knockback_y,
		"knockup": knockup,
		"knockdown": knockdown
	}
