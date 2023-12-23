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
	
	initialize_stage_select()
