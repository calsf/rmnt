extends StageSelect


func _ready():
	stages = [
		load("res://stages/Stage001.tscn"),
		load("res://stages/Stage001.tscn"),
		load("res://stages/Stage001.tscn"),
		load("res://stages/Stage001.tscn")
	]
	initialize_stage_select()
