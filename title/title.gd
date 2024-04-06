extends Node2D

onready var _fade = $CanvasLayer/Fade

var is_exiting = false
var can_input = false


func _input(event):
	# Press any key to continue to main stage
	if can_input and (!is_exiting and event is InputEventKey):
		is_exiting = true
		_fade.go_to_scene("res://stages/main/StageMain.tscn")


# Wait for initial fade before allowing input
func _on_Fade_fade_out_finished():
	can_input = true


# For animation
func _play_music(music : String):
	MusicGlobal.play("Title")
