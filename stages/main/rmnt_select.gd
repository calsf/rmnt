extends HBoxContainer

const SWAP_DELAY = 1.6

onready var rmnts := [
	get_tree().current_scene.get_node("World/RM001"),
	get_tree().current_scene.get_node("World/RM002"),
	get_tree().current_scene.get_node("World/RM003"),
	get_tree().current_scene.get_node("World/RM004")
]
onready var rmnt_unselected_textures := [
	load("res://stages/main/RM001-Icon.png"),
	load("res://stages/main/RM002-Icon.png"),
	load("res://stages/main/RM003-Icon.png"),
	load("res://stages/main/RM004-Icon.png")
	]
onready var rmnt_selected_textures := [
	load("res://stages/main/RM001-IconSelected.png"),
	load("res://stages/main/RM002-IconSelected.png"),
	load("res://stages/main/RM003-IconSelected.png"),
	load("res://stages/main/RM004-IconSelected.png")
	]
onready var swap_timer = $Timer

var rmnt_options := []
var last_rmnt_i : int
var curr_rmnt_i : int
var min_rmnt_i : int
var max_rmnt_i : int
var activated := true


func _ready():
	rmnt_options = get_children()
	
	# Min and max index should ignore the left and right arrow textures
	# Also ignore timer child object
	min_rmnt_i = 1
	max_rmnt_i = rmnt_options.size() - 3
	
	for rmnt in rmnts:
		rmnt.init_hud()
	
	# Activate selected rmnt from save data, add offset of min_rmnt_i
	curr_rmnt_i = min_rmnt_i + SaveLoadManager.get_selected_rmnt_i()
	_select_rmnt(curr_rmnt_i)


func _input(event):
	if not activated:
		return
	
	if not swap_timer.is_stopped():
		return
	
	if event.is_action_pressed("next"):
		last_rmnt_i = curr_rmnt_i
		curr_rmnt_i += 1
		if curr_rmnt_i > max_rmnt_i:
			curr_rmnt_i = min_rmnt_i
		
		_select_rmnt(curr_rmnt_i)
	elif event.is_action_pressed("prev"):
		last_rmnt_i = curr_rmnt_i
		curr_rmnt_i -= 1
		if curr_rmnt_i < min_rmnt_i:
			curr_rmnt_i = max_rmnt_i
		
		_select_rmnt(curr_rmnt_i)


func _select_rmnt(selected_index : int):
	swap_timer.start(SWAP_DELAY)
	
	var original_position = rmnts[last_rmnt_i - min_rmnt_i].global_position
	#var original_child_position = rmnts[last_rmnt_i - min_rmnt_i].get_player_child().global_position
	
	# Despawn last rmnt option, if not applicable, stop swap timer so can swap
	if rmnts[last_rmnt_i - min_rmnt_i].visible and rmnts[last_rmnt_i - min_rmnt_i].state_machine != null:
		rmnts[last_rmnt_i - min_rmnt_i].state_machine.transition_to("Despawn", {
			delay = 0,
			instant_despawn = true
		})
		yield(rmnts[last_rmnt_i - min_rmnt_i].anim, "animation_finished")
	else:
		swap_timer.stop()
	
	# Iterate through each rmnt option
	for i in range(rmnt_options.size() - 1):
		# If outside of range, ignore
		# This is because of the left and right arrow textures that are not valid rmnt selections
		if i > max_rmnt_i or i < min_rmnt_i:
			continue
		
		# Set textures for rmnt options, activate/deactivate rmnt object, and save selection value
		# The textures and rmnts array indices need to be adjusted because
		# they only include corresponding values for the rmnt selections,
		# but rmnt options includes left and right arrows
		if i == selected_index:
			rmnt_options[i].texture = rmnt_selected_textures[i - min_rmnt_i]
			
			rmnts[i - min_rmnt_i].activate(original_position)
			rmnts[i - min_rmnt_i].set_as_player_bar()
			
			# Set selected rmnt id (does not save data)
			SaveLoadManager.set_selected_rmnt_i(i - min_rmnt_i)
		else:
			rmnt_options[i].texture = rmnt_unselected_textures[i - min_rmnt_i]
			rmnts[i - min_rmnt_i].deactivate()
		
		SaveLoadManager.save_data()

func activate():
	activated = true
	visible = true


func deactivate():
	activated = false
	visible = false
