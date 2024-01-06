extends Control

onready var unselected = load("res://stages/menus/MenuOptUnselected.png")
onready var selected = load("res://stages/menus/MenuOptSelected.png")
onready var bg = $BG

signal selected()


func set_selected():
	bg.texture = selected


func set_unselected():
	bg.texture = unselected	


func trigger_selection():
	emit_signal("selected")
