extends StageNormal


func _ready():
	# EN000, EN001, EN006, EN004, EN005, EN002
	
	# Init stage props
	final_enemy = Enemies.BS001
	
	enemy_listing = [
		[Enemies.EN000],
		[Enemies.EN001],
		[Enemies.EN001],
		[Enemies.METER],
		[Enemies.EN001],
		[Enemies.EN000, Enemies.EN001],
		[Enemies.EN001],
		[Enemies.EN004, Enemies.EN001],
		[Enemies.EN004],
		[Enemies.EN004, Enemies.EN001, Enemies.EN001],
		[Enemies.EN006, Enemies.EN004],
		[Enemies.EN001],
		[Enemies.EN001, Enemies.EN006, Enemies.EN004],
		[Enemies.EN001, Enemies.EN002, Enemies.EN004],
		[Enemies.EN006],
		[Enemies.EN001, Enemies.EN002, Enemies.EN006],
		[Enemies.EN004, Enemies.EN001],
		[Enemies.HEALTH],
		[Enemies.EN005],
		[Enemies.EN001, Enemies.EN002, Enemies.EN004],
		[Enemies.EN002],
		[Enemies.EN001, Enemies.EN000, Enemies.EN006],
		[Enemies.EN002, Enemies.EN005, Enemies.EN001],
		[Enemies.EN004, Enemies.EN006, Enemies.EN001],
		[Enemies.EN002],
		[Enemies.EN001],
		[Enemies.EN006],
		[Enemies.METER],
		[Enemies.EN004, Enemies.EN002],
		[Enemies.EN005],
		[Enemies.EN002, Enemies.EN001],
		[Enemies.EN001, Enemies.EN002, Enemies.EN000],
		[Enemies.EN002],
		[Enemies.EN004, Enemies.EN005],
		[Enemies.EN002],
		[Enemies.EN005],
		[Enemies.EN001, Enemies.EN002],
		[Enemies.EN001, Enemies.EN002, Enemies.EN005],
		[Enemies.EN001, Enemies.EN001],
		[Enemies.EN000, Enemies.EN006],
		[Enemies.EN002],
		[Enemies.EN001, Enemies.EN000, Enemies.EN005],
		[Enemies.EN002, Enemies.EN006, Enemies.EN001],
		[Enemies.EN004, Enemies.EN002, Enemies.EN001],
		[Enemies.METER],
		[Enemies.EN006, Enemies.EN000, Enemies.EN002],
		[Enemies.EN005, Enemies.EN004, Enemies.EN001],
		[Enemies.EN002],
		[Enemies.EN002, Enemies.EN001],
		[Enemies.EN002, Enemies.EN001],
		[Enemies.EN002, Enemies.EN005],
		[Enemies.EN001, Enemies.EN002, Enemies.EN005],
		[Enemies.EN001],
		[Enemies.EN005, Enemies.EN004, Enemies.EN001],
		[Enemies.EN002, Enemies.EN004, Enemies.EN000],
		[Enemies.EN002],
		[Enemies.EN001, Enemies.EN005],
		[Enemies.EN001],
	]
	
	start_spawn_num = 3
	max_spawn_num = enemy_listing.size() - 1
	curr_spawn_num = 0

	# Spawn min-max enemies every min-max time
	min_enemy_num = 3
	max_enemy_num = 4
	min_time = 10
	max_time = 20
	
	# Replaces min_enemy_num and max_enemy_num
	# Min-max enemy numbers to be used after certain spawn threshold
	min_enemy_num_high = 4
	max_enemy_num_high = 6
	
	# Spawn bounds
	min_x = 16
	max_x = 304
	
	min_y = 160
	max_y = 64
	
	spawn_initial_enemies()
