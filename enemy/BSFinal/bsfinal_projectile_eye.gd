extends Projectile

onready var players = get_tree().get_nodes_in_group("players")
onready var sprite_offset = $Projectile/Sprite.position


func _ready():
	# Assumes hitbox object is index 2
	projectile_hitbox = $Projectile.get_child(2)
	_move(0)


func _move(delta):
	for player in players:
		if player.visible:
			global_position = player.global_position
			projectile_sprite.position = player.get_player_child().position + sprite_offset
			projectile_hitbox.position = projectile_sprite.position


func bound_check():
	return
