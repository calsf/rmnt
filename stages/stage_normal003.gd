extends StageNormal


func _ready():
	# EN007, EN002, EN010, EN003, EN008, EN009, EN011
	
	# Init stage props
	final_enemy = Enemies.BS003
	
	enemy_listing = [
		[Enemies.EN007],
		[Enemies.EN002],
		[Enemies.EN007],
		[Enemies.EN010],
		[Enemies.EN007, Enemies.EN002, Enemies.EN003],
		[Enemies.EN007, Enemies.EN002, Enemies.EN003],
		[Enemies.EN009],
		[Enemies.EN007, Enemies.EN002, Enemies.EN003],
		[Enemies.EN010],
		[Enemies.EN010, Enemies.EN003],
		[Enemies.EN008, Enemies.EN007],
		[Enemies.EN008, Enemies.EN002],
		[Enemies.EN009],
		[Enemies.METER],
		[Enemies.EN009],
		[Enemies.EN002, Enemies.EN007],
		[Enemies.EN002, Enemies.EN003],
		[Enemies.EN010, Enemies.EN007],
		[Enemies.EN010, Enemies.EN009],
		[Enemies.EN008, Enemies.EN007],
		[Enemies.EN002],
		[Enemies.EN009],
		[Enemies.EN007],
		[Enemies.EN009],
		[Enemies.EN003],
		[Enemies.METER],
		[Enemies.EN010],
		[Enemies.EN011],
		[Enemies.EN010],
		[Enemies.EN010, Enemies.EN003],
		[Enemies.EN008, Enemies.EN007],
		[Enemies.EN011, Enemies.EN010],
		[Enemies.METER],
		[Enemies.EN007, Enemies.EN009],
		[Enemies.EN011, Enemies.EN010],
		[Enemies.EN002],
		[Enemies.HEALTH],
		[Enemies.EN007, Enemies.EN003],
		[Enemies.EN011],
		[Enemies.EN011, Enemies.EN007],
		[Enemies.EN011, Enemies.EN009],
		[Enemies.EN002, Enemies.EN010],
		[Enemies.EN002],
		[Enemies.METER],
		[Enemies.EN008, Enemies.EN011],
		[Enemies.EN007],
		[Enemies.EN007],
		[Enemies.EN008],
		[Enemies.EN010, Enemies.EN009, Enemies.EN003],
		[Enemies.EN011, Enemies.EN002],
		[Enemies.METER],
		[Enemies.EN002, Enemies.EN009],
		[Enemies.EN011],
		[Enemies.EN007, Enemies.EN002, Enemies.EN010, Enemies.EN003],
		[Enemies.EN008, Enemies.EN009, Enemies.EN011],
		[Enemies.EN007, Enemies.EN002, Enemies.EN010, Enemies.EN003],
		[Enemies.EN008, Enemies.EN009, Enemies.EN011],
		[Enemies.EN007, Enemies.EN002, Enemies.EN010, Enemies.EN003],
		[Enemies.EN008, Enemies.EN009, Enemies.EN011]
	]
	
	start_spawn_num = 3
	max_spawn_num = enemy_listing.size() - 1
	curr_spawn_num = 0

	# Spawn min-max enemies every min-max time
	min_enemy_num = 3
	max_enemy_num = 5
	min_time = 25
	max_time = 35
	
	# Replaces min_enemy_num and max_enemy_num
	# Min-max enemy numbers to be used after certain spawn threshold
	min_enemy_num_high = 4
	max_enemy_num_high = 6
	
	# Spawn bounds
	min_x = 16
	max_x = 304
	
	min_y = 160
	max_y = 71
	
	spawn_initial_enemies()
