extends Node
class_name StageMobs

const Enemies = {
	EN000 = "res://enemy/EN000/EN000.tscn",
	EN001 = "res://enemy/EN001/EN001.tscn",
	EN002 = "res://enemy/EN002/EN002.tscn",
	EN003 = "res://enemy/EN003/EN003.tscn",
	EN004 = "res://enemy/EN004/EN004.tscn",
	EN005 = "res://enemy/EN005/EN005.tscn",
	EN006 = "res://enemy/EN006/EN006.tscn",
	EN007 = "res://enemy/EN007/EN007.tscn",
	EN008 = "res://enemy/EN008/EN008.tscn",
	EN009 = "res://enemy/EN009/EN009.tscn",
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
	# Stop spawning after maxed
	if curr_spawn_num >= max_spawn_num:
		return
	
	if spawn_timer.is_stopped():
		# Spawn random number of enemies
		var spawn_num = randi() % max_enemy_num + min_enemy_num
		
		# Limit max number of active enemies
		# Spawn only as much as possible before reaching limit
		if curr_spawn_num + spawn_num > Global.MAX_ACTIVE_ENEMIES:
			spawn_num = Global.MAX_ACTIVE_ENEMIES - curr_spawn_num 
		
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


# Spawns first set of enemies
func spawn_initial_enemies():
	# Start timer to any long length of time to delay scheduled spawning
	spawn_timer.start(max_time)
	
	yield(get_tree().create_timer(.7), "timeout")
	spawn_enemies(start_spawn_num)
	reset_spawn_time()


# Spawn spawn_num of enemies and update curr_spawn_count
func spawn_enemies(spawn_num : int) -> void:
	for i in range(curr_spawn_num , curr_spawn_num + spawn_num):
		spawn_enemy(i)
	
	# Update curr count
	curr_spawn_num = curr_spawn_num + spawn_num
	
	# Update all enemy collision exceptions after spawning enemies
	# This is so enemy ground collisions only collide with their own ground collisions
	get_tree().call_group("enemies", "update_enemy_collision_exceptions")


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
