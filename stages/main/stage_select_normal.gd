extends StageSelect


func _ready():
	stages = [
		"res://stages/Stage001.tscn",
		"res://stages/Stage002.tscn",
		"res://stages/Stage003.tscn",
	]
	
	stage_icons = [
		load("res://stages/Stage001-Select.png"),
		load("res://stages/Stage002-Select.png"),
		load("res://stages/Stage003-Select.png")
	]
	
	var stage_unlocks = SaveLoadManager.get_normal_stage_unlocks()
	for i in range(0, stage_icons.size()):
		if not stage_unlocks[i]:
			stage_icons[i] = load("res://stages/StageLocked.png")
	
	initialize_stage_select()


func validate() -> bool:
	var stage_unlocks = SaveLoadManager.get_normal_stage_unlocks()
	return stage_unlocks[curr_stage_i]
