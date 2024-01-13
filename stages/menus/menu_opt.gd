extends Control

export var label_path : String

onready var unselected = load("res://stages/menus/MenuOptUnselected.png")
onready var selected = load("res://stages/menus/MenuOptSelected.png")
onready var bg = $BG
onready var label = $Label

signal selected()


func _ready():
	label.texture = load(label_path)


func set_selected():
	bg.texture = selected


func set_unselected():
	bg.texture = unselected	


func trigger_selection():
	emit_signal("selected")
