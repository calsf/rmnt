class_name Projectile
extends Node2D

export var _speed_x := 0
export var _speed_y := 0
export var min_y := 0
export var has_y_movement := false
export var destroy_on_enemy_hit := true

onready var projectile_sprite = $Projectile/Sprite
onready var projectile_hitbox = $Projectile/PlayerHitbox

var dir : Vector2
var is_facing_left := false


func _process(delta):
	_move(delta)


func _move(delta):
	position += (dir * _speed_x) * delta
	
	# Move projectile child sprite down, destroys projectile once reaches min_y
	if has_y_movement:
		if projectile_sprite.position.y >= min_y:
			projectile_sprite.position.y = min_y
			projectile_hitbox.position.y = min_y
			destroy()
		else:
			projectile_sprite.position += (Vector2.DOWN * _speed_y) * delta
			projectile_hitbox.position = projectile_sprite.position


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


func set_offset_y(offset : Vector2) -> void:
	projectile_sprite.position += offset
	projectile_hitbox.position += offset


func destroy() -> void:
	queue_free()
