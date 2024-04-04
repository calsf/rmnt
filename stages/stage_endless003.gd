extends StageEndless


func _ready():
	# EN007, EN002, EN010, EN003, EN008, EN009, EN011
	
	SoundsGlobal.play("AmbienceStage03")
	
	# Init stage props
	boss_enemy = Enemies.BS003
	
	normal_enemy_listing = [
		Enemies.EN007,
		Enemies.EN002,
		Enemies.EN010,
		Enemies.EN003,
		Enemies.EN008,
		Enemies.EN009,
		Enemies.EN011
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
	max_y = 71
	
	spawn_initial_enemies()
