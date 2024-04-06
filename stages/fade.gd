extends ColorRect

signal fade_in_finished
signal fade_out_finished

onready var anim = $AnimationPlayer

var _in_transition = false
var _next_scene = ""


func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS	# This will never pause
	#hide()


# Sets next scene to go to and play fade in animation
func go_to_scene(scene_name):
	if not _in_transition:
		SoundsGlobal.stop_all()
		MusicGlobal.stop_all()
		Global.reset_kill_count()
		_in_transition = true
		_next_scene = scene_name
		color.a = 0
		show()
		fade_in()


func fade_in():
	anim.play("FadeIn")


func fade_out():
	anim.play("FadeOut")


func _on_AnimationPlayer_animation_finished(anim_name):
	match (anim_name):
		"FadeIn":	# Reload current scene if no next scene specified
			if _next_scene == "":
				get_tree().reload_current_scene()
			else:
				get_tree().change_scene(_next_scene)
			
			# Make sure to unpause after loading new scene if was paused previously
			if get_tree().paused:
				get_tree().paused = false
			emit_signal("fade_in_finished")
		"FadeOut": 
			emit_signal("fade_out_finished")
