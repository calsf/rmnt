extends Node
class_name StageNormal

const Enemies = {
	BS001 = "res://enemy/BS001/BS001.tscn",
	BS002 = "res://enemy/BS002/BS002.tscn",
	BS003 = "res://enemy/BS003/BS003.tscn",
	HEALTH = "res://enemy/Potions/PotionHealth.tscn",
	METER = "res://enemy/Potions/PotionMeter.tscn",
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
	EN010 = "res://enemy/EN010/EN010.tscn",
	EN011 = "res://enemy/EN011/EN011.tscn"
}

# Corresponds to indices in save data e.g 0, 1, or 2
export var stage_num : int

onready var _fade = get_tree().current_scene.get_node("HUD/Fade")

var enemy_listing : Array

var start_spawn_num : int
var max_spawn_num : int
var curr_spawn_num : int

# Spawn min-max enemies every min-max time
var min_enemy_num : int
var max_enemy_num : int
var min_time : float
var max_time : float

# Replaces min_enemy_num and max_enemy_num
# Min-max enemy numbers to be used after certain spawn threshold
var min_enemy_num_high : int
var max_enemy_num_high : int

# Spawn bounds
var min_x : float
var max_x :float
var min_y : float
var max_y : float

# Final enemy
var final_enemy := ""

var rng := RandomNumberGenerator.new()

var final_enemy_spawned := false
var is_cleared := false
var first_spawn := false

onready var spawn_timer = $SpawnTimer


func _process(delta):
	# Stop spawning after reaching maxed overall limit
	# max_spawn_num is enemy_listing.size() - 1 so need to minus 1 from curr_spawn_num
	if (curr_spawn_num - 1) >= max_spawn_num:
		var active_spawn_num = get_tree().get_nodes_in_group("enemies").size()
		
		# If reached max overall limit and no more active enemies, spawn final enemy
		if active_spawn_num == 0 and not final_enemy_spawned:
			final_enemy_spawned = true
			
			var x = rand_range(min_x, max_x)
			var y = rand_range(min_y, max_y)
			
			var enemy = load(final_enemy).instance()
			enemy.set_stage_bounds(min_x, max_x, min_y, max_y)
			enemy.global_position = Vector2(x, y)
			get_tree().current_scene.get_node("World").add_child(enemy)
			return
		
		# If reached maxed overall limit, final enemy spawned, and no more active enemies, stage is cleared
		if active_spawn_num == 0 and final_enemy_spawned and not is_cleared:
			is_cleared = true
			for player in get_tree().get_nodes_in_group("players"):
				if player.visible:
					# Update normal stage as cleared
					var stage_clears = SaveLoadManager.get_normal_stage_clears()
					stage_clears[stage_num] = true
					SaveLoadManager.set_normal_stage_clears(stage_clears)
					
					# Unlock next normal stage
					var normal_stage_unlocks = SaveLoadManager.get_normal_stage_unlocks()
					if stage_num + 1 < normal_stage_unlocks.size():
						normal_stage_unlocks[stage_num + 1] = true
						SaveLoadManager.set_normal_stage_unlocks(normal_stage_unlocks)
					
					# Unlock corresponding endless stage
					var endless_stage_unlocks = SaveLoadManager.get_endless_stage_unlocks()
					endless_stage_unlocks[stage_num] = true
					SaveLoadManager.set_endless_stage_unlocks(endless_stage_unlocks)
					
					# Save
					SaveLoadManager.save_data()
					
					# Force transition to despawn
					player.state_machine.transition_to("Despawn")
					
					# Wait and then return to main stage
					get_tree().current_scene.get_node("HUD/PauseMenu").can_pause = false
					yield(get_tree().create_timer(2.5, false), "timeout")
					_fade.go_to_scene("res://stages/main/StageMain.tscn")
		
		return
	
	# Stop spawning after reaching max active limit
	var active_spawn_num = get_tree().get_nodes_in_group("enemies").size()
	if active_spawn_num >= Global.MAX_ACTIVE_ENEMIES:
		# Reset spawn timer so enemies aren't spawned immediately after falling below max active threshold
		reset_spawn_time()
		return
	
	# Spawn enemies periodically or when active enemies are 0
	if spawn_timer.is_stopped() or (curr_spawn_num > 0 and active_spawn_num == 0):
		# Spawn random number of enemies
		var spawn_num = 0
		if curr_spawn_num >= (max_spawn_num / 3):
			# Past threshold, use higher spawn nums
			spawn_num = rng.randi_range(min_enemy_num_high, max_enemy_num_high)
		else:
			# Regular spawn nums
			spawn_num = rng.randi_range(min_enemy_num, max_enemy_num)
		
		# Handle initial spawns
		if first_spawn:
			spawn_num = start_spawn_num
			first_spawn = false
		
		if (curr_spawn_num - 1) + spawn_num > max_spawn_num:
			# Spawn only as much as possible before reaching overall limit
			spawn_num = max_spawn_num - (curr_spawn_num - 1)
		elif active_spawn_num + spawn_num > Global.MAX_ACTIVE_ENEMIES:
			# Limit max number of active enemies
			spawn_num = Global.MAX_ACTIVE_ENEMIES - active_spawn_num
		
		if spawn_num < 0:
			spawn_num = 0
		
		spawn_enemies(spawn_num)
		
		reset_spawn_time()
	else:
		return


# Reset spawn timer
func reset_spawn_time():
	var wait = rand_range(min_time, max_time)
	spawn_timer.start(wait)


# Spawns first set of enemies
func spawn_initial_enemies():
	rng.randomize()
	
	# Start timer to any long length of time to delay scheduled spawning
	first_spawn = true
	spawn_timer.start(2)


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
