class_name Projectile
extends Node2D

export var _speed := 0
export var destroy_on_enemy_hit := true

var dir : Vector2
var is_facing_left := false


func _process(delta):
	_move(delta)


func _move(delta):
	position += (dir * _speed) * delta


func set_dir(new_dir : Vector2) -> void:
	dir = new_dir
	turn(dir.x)


func turn(facing_x) -> void:
	if facing_x < 0 and scale.y > 0:
		self.scale.y = -1
		self.rotation_degrees = 180
		is_facing_left = true
	elif facing_x > 0 and scale.y < 0:
		self.scale.y = 1
		self.rotation_degrees = 0
		is_facing_left = false


func destroy() -> void:
	queue_free()
