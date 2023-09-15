class_name PlayerInteractBox
extends Area2D


func _init():
	# PlayerInteractBox layer
	collision_layer = 4096
	
	# Collide with nothing
	collision_mask = 0
