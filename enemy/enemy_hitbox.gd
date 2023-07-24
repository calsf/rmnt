class_name EnemyHitbox
extends Area2D

export var damage := 0.0
export var knockback_x := 0.0
export var knockback_y := 0.0
export var knockup := 0.0


func _init():
	# EnemyHitbox layer
	collision_layer = 32
	
	# Collide with nothing
	collision_mask = 0


func _ready():
	# Disable hitbox collision shapes on initial load
	for collision in get_children():
		# collision.disabled = true
		return


func get_data_state() -> Dictionary:
	var x = knockback_x
	
	return {
		"damage": damage,
		"knockback_x": x,
		"knockback_y": knockback_y,
		"knockup": knockup
	}
