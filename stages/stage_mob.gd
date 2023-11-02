extends Node
class_name StageMob

const Enemies = {
	EN001 = "res://enemy/EN001/EN001.tscn",
	EN002 = "res://enemy/EN002/EN002.tscn",
	EN003 = "res://enemy/EN003/EN003.tscn",
	EN004 = "res://enemy/EN004/EN004.tscn"
}

var enemy_listing : Array

var start_spawn_num : int
var max_spawn_num : int
var curr_spawn_num : int

# Spawn min-max enemies every min-max time
var min_enemy_num : int
var max_enemy_num : int
var min_time : float
var max_time : float

# Spawn bounds
var min_x : float
var max_x :float
var min_y : float
var max_y : float

onready var spawn_timer = $SpawnTimer

func _process(delta):
	if spawn_timer.is_stopped():
		# Spawn random number of enemies
		var spawn_num = randi() % max_enemy_num + min_enemy_num
		spawn_enemies(spawn_num)
		
		# Update curr count
		curr_spawn_num = curr_spawn_num + spawn_num
		
		reset_spawn_time()
	else:
		return


# Reset spawn timer
func reset_spawn_time():
	var wait = rand_range(min_time, max_time)
	spawn_timer.start(wait)


# Spawn spawn_num of enemies and update curr_spawn_count
func spawn_enemies(spawn_num : int) -> void:
	for i in range(curr_spawn_num , curr_spawn_num + spawn_num):
		spawn_enemy(i)
	
	# Update curr count
	curr_spawn_num = curr_spawn_num + spawn_num


# Spawns a single enemy, requires the enemy num to be specified
func spawn_enemy(i : int) -> void:
	if i > max_spawn_num:
		return
	
	# Randomize location
	var x = rand_range(min_x, max_x)
	var y = rand_range(min_y, max_y)
	
	var possible_enemies = enemy_listing[i]
	
	# Randomize enemy
	var enemy_path = possible_enemies[randi() % possible_enemies.size()]
	
	var enemy = load(enemy_path).instance()
	enemy.set_stage_bounds(min_x, max_x, min_y, max_y)
	enemy.global_position = Vector2(x, y)
	get_tree().current_scene.get_node("World").add_child(enemy)
