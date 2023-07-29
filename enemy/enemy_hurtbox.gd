class_name EnemyHurtbox
extends Area2D

# Areas currently overlapping with hurtbox
var _curr_areas := []


func _init() -> void:
	# No collision layer
	collision_layer = 0
	
	# Collide with PlayerHitbox layers
	collision_mask = 4


func _ready():
	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_on_area_exited")


func _physics_process(delta):
	# Re-trigger area entered behavior as needed
	for area in _curr_areas:
		_on_area_entered(area)


func _on_area_entered(player_hitbox : PlayerHitbox) -> void:
	if player_hitbox == null:
		return
	
	# Objects may not be in same lane on area entered and may enter lane while still overlapping
	# Keep track of reference to area to keep checking for collision in _physics_process
	# If hit, remove the reference to stop checking
	if owner.has_method("on_enemy_hurtbox_hit"):
		if owner.on_enemy_hurtbox_hit(player_hitbox.get_data_state(), player_hitbox.owner, player_hitbox):
			_on_area_exited(player_hitbox)
		elif not _curr_areas.has(player_hitbox):
			_curr_areas.append(player_hitbox)


func _on_area_exited(area) -> void:
	# Also remove reference on area exit
	var area_remove = _curr_areas.find(area)
	if area_remove == -1:
		return
	
	_curr_areas.remove(area_remove)
