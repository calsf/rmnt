extends StageSelect


func _ready():
	stages = [
		load("res://stages/main/StageMain.tscn"),
		load("res://stages/main/StageMain.tscn"),
		load("res://stages/main/StageMain.tscn"),
		load("res://stages/main/StageMain.tscn")
	]
	initialize_stage_select()
