extends StageMobs


func _ready():
	# Init stage props
	enemy_listing = [
		[Enemies.HEALTH],
		[Enemies.METER],
		[Enemies.EN003],
		[Enemies.EN011],
		#[Enemies.EN011],
		#[Enemies.EN001, Enemies.EN002, Enemies.EN003],
#		[Enemies.EN001, Enemies.EN002, Enemies.EN003],
#		[Enemies.EN004],
#		[Enemies.EN001, Enemies.EN002, Enemies.EN003],
#		[Enemies.EN001, Enemies.EN002, Enemies.EN003],
#		[Enemies.EN001, Enemies.EN002, Enemies.EN003],
#		[Enemies.EN001, Enemies.EN002, Enemies.EN003],
#		[Enemies.EN001, Enemies.EN002, Enemies.EN003],
#		[Enemies.EN001, Enemies.EN002, Enemies.EN003],
#		[Enemies.EN001, Enemies.EN002, Enemies.EN003],
#		[Enemies.EN001, Enemies.EN002, Enemies.EN003],
#		[Enemies.EN001, Enemies.EN002, Enemies.EN003],
#		[Enemies.EN001, Enemies.EN002, Enemies.EN003],
#		[Enemies.EN001, Enemies.EN002, Enemies.EN003],
	]
	
	start_spawn_num = 3
	max_spawn_num = enemy_listing.size() - 1
	curr_spawn_num = 0

	# Spawn min-max enemies every min-max time
	min_enemy_num = 2
	max_enemy_num = 4
	min_time = 2
	max_time = 5
	
	# Spawn bounds
	min_x = 16
	max_x = 304
	
	min_y = 160
	max_y = 64
	
	spawn_initial_enemies()
