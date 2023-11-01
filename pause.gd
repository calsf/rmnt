# Hitstop singleton
extends Node


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
