extends StageMobs


func _ready():
	# EN001, EN007, EN005, EN004, EN010, EN003, EN008
	
	# Init stage props
	enemy_listing = [
		[Enemies.EN001],
		[Enemies.EN007],
		[Enemies.EN001],
		[Enemies.EN004],
		[Enemies.EN005],
		[Enemies.EN007, Enemies.EN001],
		[Enemies.EN003],
		[Enemies.EN004, Enemies.EN007],
		[Enemies.EN005, Enemies.EN007],
		[Enemies.EN005, Enemies.EN004],
		[Enemies.EN001],
		[Enemies.EN007, Enemies.EN001],
		[Enemies.EN003],
		[Enemies.METER],
		[Enemies.EN003],
		[Enemies.EN007, Enemies.EN001, Enemies.EN005],
		[Enemies.EN001, Enemies.EN005],
		[Enemies.EN010],
		[Enemies.EN003],
		[Enemies.EN001, Enemies.EN003],
		[Enemies.EN003],
		[Enemies.EN001],
		[Enemies.EN005],
		[Enemies.EN007],
		[Enemies.METER],
		[Enemies.EN007, Enemies.EN001, Enemies.EN010],
		[Enemies.EN001, Enemies.EN003],
		[Enemies.EN007, Enemies.EN003],
		[Enemies.EN010, Enemies.EN005],
		[Enemies.HEALTH],
		[Enemies.EN008],
		[Enemies.EN007, Enemies.EN003],
		[Enemies.EN010, Enemies.EN001],
		[Enemies.EN001, Enemies.EN010, Enemies.EN003],
		[Enemies.EN008, Enemies.EN003],
		[Enemies.EN001],
		[Enemies.EN001],
		[Enemies.EN008],
		[Enemies.EN004, Enemies.EN003, Enemies.EN001],
		[Enemies.METER],
		[Enemies.EN003],
		[Enemies.EN001],
		[Enemies.EN010],
		[Enemies.EN007, Enemies.EN010, Enemies.EN003, Enemies.EN008],
		[Enemies.EN001, Enemies.EN010, Enemies.EN004, Enemies.EN008],
		[Enemies.EN005, Enemies.EN010, Enemies.EN003, Enemies.EN004],
		[Enemies.EN007, Enemies.EN008, Enemies.EN003],
		[Enemies.EN001, Enemies.EN008, Enemies.EN003],
		[Enemies.METER],
		[Enemies.EN004, Enemies.EN008, Enemies.EN003],
		[Enemies.EN001],
		[Enemies.EN003],
		[Enemies.EN008],
		[Enemies.EN001, Enemies.EN010],
		[Enemies.EN005],
		[Enemies.EN008, Enemies.EN007, Enemies.EN001],
		[Enemies.EN007],
		[Enemies.EN001]
	]
	
	start_spawn_num = 3
	max_spawn_num = enemy_listing.size() - 1
	curr_spawn_num = 0

	# Spawn min-max enemies every min-max time
	min_enemy_num = 3
	max_enemy_num = 5
	min_time = 15
	max_time = 20
	
	# Replaces min_enemy_num and max_enemy_num
	# Min-max enemy numbers to be used after certain spawn threshold
	min_enemy_num_high = 4
	max_enemy_num_high = 6
	
	# Spawn bounds
	min_x = 16
	max_x = 304
	
	min_y = 160
	max_y = 96
	
	spawn_initial_enemies()
