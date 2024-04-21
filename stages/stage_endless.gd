# Similar to StageNormal, but spawns a set of enemies endlessly
extends Node
class_name StageEndless

const Enemies = {
	BS001 = "res://enemy/BS001/BS001.tscn",
	BS002 = "res://enemy/BS002/BS002.tscn",
	BS003 = "res://enemy/BS003/BS003.tscn",
	BSFINAL = "res://enemy/BSFinal/BSFinal.tscn",
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
const METER_SPAWN_NUM = 5		# Chance to spawn meter every x enemy num
const HEALTH_SPAWN_NUM = 10		# Chance to spawn health every x enemy num
const INCREASE_SPAWN_NUM = 10	# Increase min and max spawn num every x enemy num
const BOSS_SPAWN_NUM = 40 # Spawn boss every x enemy num

# Corresponds to indices in save data e.g 0, 1, or 2
export var stage_num : int

onready var _fade = get_tree().current_scene.get_node("HUD/Fade")
onready var _kill_count_label = get_tree().current_scene.get_node("HUD/KillCount/Label")

# An array of possible enemies for this stage
var normal_enemy_listing : Array

# Boss enemy for this stage
var boss_enemy : String
var boss_active := false

var start_spawn_num : int
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

var rng := RandomNumberGenerator.new()

var is_cleared := false
var first_spawn := true

onready var spawn_timer = $SpawnTimer


func _process(delta):
	# Update kill count label
	_kill_count_label.text = str(Global.kill_count)
	
	if boss_active:
		var active_boss_num = get_tree().get_nodes_in_group("bosses").size()
		if active_boss_num == 0:
			boss_active = false
			MusicGlobal.play("Stage")
	
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
		spawn_num = rng.randi_range(min_enemy_num, max_enemy_num)
		
		# Handle initial spawns
		if first_spawn:
			spawn_num = start_spawn_num
			first_spawn = false
		
		if active_spawn_num + spawn_num > Global.MAX_ACTIVE_ENEMIES:
			# Limit max number of active enemies
			spawn_num = Global.MAX_ACTIVE_ENEMIES - active_spawn_num
		
		if spawn_num < 0:
			spawn_num = 0
		
		spawn_enemies(spawn_num)
		
		reset_spawn_time()
		
		# Every x enemies, increase min and max enemy spawn num
		if curr_spawn_num != 0 and curr_spawn_num % INCREASE_SPAWN_NUM == 0:
			min_enemy_num = min(min_enemy_num + 1, Global.MAX_ACTIVE_ENEMIES)
			max_enemy_num = min(max_enemy_num + 1, Global.MAX_ACTIVE_ENEMIES)
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
	# Should only ever be 1 active boss at most
	var active_boss_num = get_tree().get_nodes_in_group("bosses").size()
		
	# Spawn boss every x num of spawns and while there is no active boss enemy
	if i != 0 and i % BOSS_SPAWN_NUM == 0 and active_boss_num == 0: # Spawn boss
		var x = rand_range(min_x, max_x)
		var y = rand_range(min_y, max_y)
		
		var enemy = load(boss_enemy).instance()
		enemy.set_stage_bounds(min_x, max_x, min_y, max_y)
		enemy.global_position = Vector2(x, y)
		get_tree().current_scene.get_node("World").add_child(enemy)
		enemy.add_to_group("bosses") # Add to boss group
		
		MusicGlobal.play("BS")
		boss_active = true
	else: # Normal spawn
		# Randomize location
		var x = rand_range(min_x, max_x)
		var y = rand_range(min_y, max_y)
		
		var possible_enemies = normal_enemy_listing.duplicate()
		
		# Chance of meter every x spawns
		if i % METER_SPAWN_NUM == 0:
			possible_enemies.append(Enemies.METER)
		
		# Chance of health every x spawns
		if i % HEALTH_SPAWN_NUM == 0:
			possible_enemies.append(Enemies.HEALTH)
		
		# Randomize enemy
		var enemy_path = possible_enemies[randi() % possible_enemies.size()]
		
		var enemy = load(enemy_path).instance()
		enemy.set_stage_bounds(min_x, max_x, min_y, max_y)
		enemy.global_position = Vector2(x, y)
		get_tree().current_scene.get_node("World").add_child(enemy)


# Check and save stage scores on player death in stage.gd
func save_stage_score() -> void:
	var scores = SaveLoadManager.get_endless_stage_scores()
	if Global.kill_count > scores[stage_num]:
		scores[stage_num] = Global.kill_count
		SaveLoadManager.set_endless_stage_scores(scores)
		SaveLoadManager.save_data()
