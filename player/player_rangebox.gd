class_name PlayerRangebox
extends Area2D


func _init():
	# PlayerRangebox layer
	collision_layer = 1024
	
	# Collide with nothing
	collision_mask = 0
