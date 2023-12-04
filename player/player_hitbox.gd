class_name PlayerHitbox
extends Area2D

export var disabled_on_start := true
export var damage := 0.0
export var knockback_x := 0.0
export var knockback_y := 0.0
export var knockup := 0.0
export var knockdown := 0.0
export var meter_gain := 0.0

# For projectile hitboxes whose owner would not be Player
# Still need to reference the "player owner" to trigger meter gain
# Must be set when instancing player projectile
var player_owner = null

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
		"knockdown": knockdown,
		"meter_gain": meter_gain
	}


# Trigger meter gain, must be triggered on Player
func gain_meter() -> void:
	if player_owner == null:
		if owner.has_method("gain_meter"):
			owner.gain_meter(meter_gain)
			return
		else:
			print_debug("METER GAIN FAILED")
			return
	
	player_owner.gain_meter(meter_gain)
