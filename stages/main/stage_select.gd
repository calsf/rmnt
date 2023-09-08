extends Control

onready var unselected_icon := load("res://stages/main/StageSelectUnselected.png")
onready var selected_icon := load("res://stages/main/StageSelectSelected.png")

onready var stages := [
	load("res://stages/Stage001.tscn"),
	load("res://stages/Stage001.tscn"),
	load("res://stages/Stage001.tscn"),
	load("res://stages/Stage001.tscn")
	]

var select_icons := []
var curr_stage_i : int
var min_stage_i : int
var max_stage_i : int


func _ready():
	select_icons = get_node("Selection/SelectIcons").get_children()
	min_stage_i = 0
	max_stage_i = stages.size() - 1
	curr_stage_i = min_stage_i
	_select_stage(curr_stage_i)


func _input(event):
	if event.is_action_pressed("next"):
		curr_stage_i += 1
		if curr_stage_i > max_stage_i:
			curr_stage_i = min_stage_i
		
		_select_stage(curr_stage_i)
	elif event.is_action_pressed("prev"):
		curr_stage_i -= 1
		if curr_stage_i < min_stage_i:
			curr_stage_i = max_stage_i
		
		_select_stage(curr_stage_i)


func _select_stage(selected_index : int):
	# Iterate through each stage option
	for i in range(min_stage_i, max_stage_i + 1):
		if i == selected_index:
			select_icons[i].texture = selected_icon
		else:
			select_icons[i].texture = unselected_icon
