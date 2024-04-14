# Custom Enemy for BSFinal
extends Enemy

const Enemies = [
	"res://enemy/EN001/EN001.tscn",
	"res://enemy/EN002/EN002.tscn",
	"res://enemy/EN003/EN003.tscn",
	"res://enemy/EN004/EN004.tscn",
	"res://enemy/EN005/EN005.tscn",
	"res://enemy/EN007/EN007.tscn",
	"res://enemy/EN008/EN008.tscn",
	"res://enemy/EN009/EN009.tscn",
	"res://enemy/EN010/EN010.tscn",
	"res://enemy/EN011/EN011.tscn"
]

# Spawn bounds
var stage_min_x := 16
var stage_max_x := 304
var stage_min_y := 160
var stage_max_y := 68

var rng := RandomNumberGenerator.new()


# Spawn spawn_num of enemies and update curr_spawn_count
func spawn_enemies(spawn_num : int) -> void:
	var active_spawn_num = get_tree().get_nodes_in_group("enemies").size()
	if active_spawn_num + spawn_num > Global.MAX_ACTIVE_ENEMIES:
		# Limit max number of active enemies
		spawn_num = Global.MAX_ACTIVE_ENEMIES - active_spawn_num
	
	for i in range(0, spawn_num):
		spawn_enemy()
	
	# Update all enemy collision exceptions after spawning enemies
	# This is so enemy ground collisions only collide with their own ground collisions
	get_tree().call_group("enemies", "update_enemy_collision_exceptions")


# Spawns a single random enemy
func spawn_enemy() -> void:
	# Randomize location
	var x = rand_range(stage_min_x, stage_max_x)
	var y = rand_range(stage_min_y, stage_max_y)
	
	# Randomize enemy
	var enemy_path = Enemies[randi() % Enemies.size()]
	
	var enemy = load(enemy_path).instance()
	enemy.set_stage_bounds(stage_min_x, stage_max_x, stage_min_y, stage_max_y)
	enemy.global_position = Vector2(x, y)
	get_tree().current_scene.get_node("World").add_child(enemy)
