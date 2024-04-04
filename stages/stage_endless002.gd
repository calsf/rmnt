extends StageEndless


func _ready():
	# EN001, EN007, EN005, EN004, EN010, EN003, EN008
	
	SoundsGlobal.play("AmbienceStage02")
	
	# Init stage props
	boss_enemy = Enemies.BS002
	
	normal_enemy_listing = [
		Enemies.EN001,
		Enemies.EN007,
		Enemies.EN005,
		Enemies.EN004,
		Enemies.EN010,
		Enemies.EN003,
		Enemies.EN008
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
	max_y = 96
	
	spawn_initial_enemies()
