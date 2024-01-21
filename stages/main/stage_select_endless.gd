extends StageSelect


func _ready():
	stages = [
		"res://stages/StageEndless001.tscn",
		"res://stages/main/StageMain.tscn",
		"res://stages/main/StageMain.tscn",
	]
	
	stage_icons = [
		load("res://stages/Stage001-Select.png"),
		load("res://stages/StageLocked.png"),
		load("res://stages/StageLocked.png")
	]
	
	initialize_stage_select()
