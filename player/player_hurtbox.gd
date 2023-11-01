class_name PlayerHurtbox
extends Area2D

# Areas currently overlapping with hurtbox
var _curr_areas := []


func _init() -> void:
	# Player hurtbox collision layer
	collision_layer = 8
	
	# Collide with EnemyHitbox layers
	collision_mask = 32

func _ready():
	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_on_area_exited")


func _physics_process(delta):
	# Re-trigger area entered behavior as needed
	for area in _curr_areas:
		_on_area_entered(area)


func _on_area_entered(enemy_hitbox : EnemyHitbox) -> void:
	if enemy_hitbox == null or not is_instance_valid(enemy_hitbox):
		return
	
	# Objects may not be in same lane on area entered and may enter lane while still overlapping
	# Keep track of reference to area to keep checking for collision in _physics_process
	# If hit, remove the reference to stop checking
	if is_instance_valid(owner) and owner.has_method("on_player_hurtbox_hit"):
		if is_instance_valid(owner) and owner.on_player_hurtbox_hit(enemy_hitbox):
			_on_area_exited(enemy_hitbox)
		elif not _curr_areas.has(enemy_hitbox):
			_curr_areas.append(enemy_hitbox)


func _on_area_exited(area) -> void:
	# Also remove reference on area exit
	var area_remove = _curr_areas.find(area)
	if area_remove == -1:
		return
	
	_curr_areas.remove(area_remove)
