# General Global singleton
extends Node

# Max number of active enemies allowed in a stage at once
# Will be limited by how many can be displayed on hud
const MAX_ACTIVE_ENEMIES = 26

# Reference for endless stage kill counts
var kill_count := 0

# Used to determine what input type is being used
var is_keyboard = true


func _ready():
	# Global randomize call, only need to be called once
	randomize()


func hitstop(objects_hit := [], duration := .05) -> void:
	for obj in objects_hit:
		if is_instance_valid(obj):
			pause_scene(obj, true)
	yield(get_tree().create_timer(duration), "timeout")
	for obj in objects_hit:
		if is_instance_valid(obj):
			pause_scene(obj, false)


# Pause specific node and all the children
func pause_scene(node, is_paused):
	if not is_instance_valid(node):
		return
	
	pause_node(node, is_paused)
	for child in node.get_children():
		pause_node(child, is_paused)


# Pause specific node
func pause_node(node, is_paused):
	if not is_instance_valid(node):
		return
	
	node.set_process(!is_paused)
	node.set_physics_process(!is_paused)
	node.set_process_input(!is_paused)
	node.set_process_internal(!is_paused)
	# node.set_process_unhandled_input(!is_paused)
	# node.set_process_unhandled_key_input(!is_paused)


func add_kill_count():
	kill_count += 1


func reset_kill_count():
	kill_count = 0
