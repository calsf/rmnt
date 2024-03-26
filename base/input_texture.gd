# Switch between textures depending on last input device
extends Node

export var texture_kb_path : String
export var texture_ctrl_path : String

onready var texture_kb = load(texture_kb_path)
onready var texture_ctrl = load(texture_ctrl_path)


func _ready():
	if Global.is_keyboard:
		self.texture = texture_kb
	else:
		self.texture = texture_ctrl


func _input(event):
	if event is InputEventKey:
		Global.is_keyboard = true
		self.texture = texture_kb
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		Global.is_keyboard = false
		self.texture = texture_ctrl
