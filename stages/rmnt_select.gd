extends HBoxContainer

onready var rmnts := [
	get_tree().current_scene.get_node("World/RM001"),
	get_tree().current_scene.get_node("World/RM002"),
	get_tree().current_scene.get_node("World/RM003"),
	get_tree().current_scene.get_node("World/RM003")
]
onready var rmnt_unselected_textures := [
	load("res://stages/RM001-Icon.png"),
	load("res://stages/RM002-Icon.png"),
	load("res://stages/RM003-Icon.png"),
	load("res://stages/RM003-Icon.png")
	]
onready var rmnt_selected_textures := [
	load("res://stages/RM001-IconSelected.png"),
	load("res://stages/RM002-IconSelected.png"),
	load("res://stages/RM003-IconSelected.png"),
	load("res://stages/RM003-IconSelected.png")
	]

var rmnt_options := []
var last_rmnt_i : int
var curr_rmnt_i : int
var min_rmnt : int
var max_rmnt : int


func _ready():
	rmnt_options = get_children()
	
	# Min and max index should ignore the left and right arrow textures
	min_rmnt = 1
	max_rmnt = rmnt_options.size() - 2
	curr_rmnt_i = min_rmnt
	_select_rmnt(curr_rmnt_i)


func _input(event):
	if event.is_action_pressed("next"):
		last_rmnt_i = curr_rmnt_i
		curr_rmnt_i += 1
		if curr_rmnt_i > max_rmnt:
			curr_rmnt_i = min_rmnt
		
		_select_rmnt(curr_rmnt_i)
	elif event.is_action_pressed("prev"):
		last_rmnt_i = curr_rmnt_i
		curr_rmnt_i -= 1
		if curr_rmnt_i < min_rmnt:
			curr_rmnt_i = max_rmnt
		
		_select_rmnt(curr_rmnt_i)


func _select_rmnt(selected_index : int):
	# Iterate through each rmnt option
	for i in range(rmnt_options.size() - 1):
		# If outside of range, ignore
		# This is because of the left and right arrow textures that are not valid rmnt selections
		if i > max_rmnt or i < min_rmnt:
			continue
		
		# Set textures for rmnt options, activate/deactivate rmnt object, and save selection value
		# The textures and rmnts array indices need to be adjusted because
		# they only include corresponding values for the rmnt selections,
		# but rmnt options includes left and right arrows
		rmnts[i - min_rmnt].global_position = rmnts[last_rmnt_i - min_rmnt].global_position
		if i == selected_index:
			rmnt_options[i].texture = rmnt_selected_textures[i - min_rmnt]
			
			rmnts[i - min_rmnt].visible = true
			#TODO: Save selected value
		else:
			rmnt_options[i].texture = rmnt_unselected_textures[i - min_rmnt]
			
			rmnts[i - min_rmnt].visible = false
			#TODO: Save selected value
