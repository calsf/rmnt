class_name StageSelect
extends Control

onready var unselected_icon := load("res://stages/main/StageSelectUnselected.png")
onready var selected_icon := load("res://stages/main/StageSelectSelected.png")
onready var preview = $Selection/Preview
onready var players = get_tree().get_nodes_in_group("players")
onready var _fade = get_tree().current_scene.get_node("HUD/Fade")

# An array of stage scene paths
# To be set by child class
onready var stages := []

# Parallel array for corresponding stage icons for stages
# To be set by child class
onready var stage_icons := []

var select_icons := []
var curr_stage_i : int
var min_stage_i : int
var max_stage_i : int
var activated := false


func initialize_stage_select():
	select_icons = get_node("Selection/SelectIcons").get_children()
	min_stage_i = 0
	max_stage_i = stages.size() - 1
	curr_stage_i = min_stage_i
	_select_stage(curr_stage_i)
	deactivate()


func _input(event):
	if not activated:
		return
	
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
	
	# "Enter" stage
	if event.is_action_pressed("attack_a"):
		# Validate if can enter
		if not validate():
			return
		
		# Deactivate stage select
		deactivate()
		
		# Hide players
		for player in players:
			player.visible = false
		
		# Go to select scene
		_fade.go_to_scene(stages[curr_stage_i])


func _select_stage(selected_index : int):
	preview.texture = stage_icons[selected_index]
	# Iterate through each stage option
	for i in range(min_stage_i, max_stage_i + 1):
		if i == selected_index:
			select_icons[i].texture = selected_icon
		else:
			select_icons[i].texture = unselected_icon


func activate():
	activated = true
	visible = true


func deactivate():
	activated = false
	visible = false


func validate() -> bool:
	return false
