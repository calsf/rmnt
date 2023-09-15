extends StageSelect


func _ready():
	stages = [
		"res://stages/main/StageMain.tscn",
		"res://stages/main/StageMain.tscn",
		"res://stages/main/StageMain.tscn",
		"res://stages/main/StageMain.tscn"
	]
	initialize_stage_select()
