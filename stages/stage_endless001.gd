extends StageEndless


func _ready():
	# EN000, EN001, EN006, EN004, EN005, EN002
	
	SoundsGlobal.play("AmbienceStage01")
	
	# Init stage props
	boss_enemy = Enemies.BS001
	
	normal_enemy_listing = [
		Enemies.EN000,
		Enemies.EN001,
		Enemies.EN006,
		Enemies.EN004,
		Enemies.EN005,
		Enemies.EN002
	]
	
	start_spawn_num = 4
	curr_spawn_num = 0

	# Spawn min-max enemies every min-max time
	min_enemy_num = 4
	max_enemy_num = 6
	min_time = 15
	max_time = 25
	
	# Spawn bounds
	min_x = 16
	max_x = 304
	
	min_y = 160
	max_y = 64
	
	spawn_initial_enemies()
