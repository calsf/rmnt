extends Control

onready var _fade = get_tree().current_scene.get_node("HUD/Fade")
onready var _back_label = $BackLabel
onready var _confirm_label = $ConfirmLabel
onready var _resume_opt = $MenuOptions/Resume
onready var _config_opt = $MenuOptions/Config
onready var _guide_opt = $MenuOptions/Guide
onready var _quit_opt = $MenuOptions/Quit
onready var _guide_screen = $GuideScreen
onready var _menu_options = $MenuOptions
onready var _config_options = $ConfigOptions

var unfocused := false # If no longer focused on pause menu
var menu_options := []
var last_option_i := -1
var menu_paused := false # If pause menu is what triggered pause
var can_pause := true

# Path to the scene to quit to, set from parent HUD
var quit_to_scene : String


func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS	# This will never pause
	visible = false
	_confirm_label.visible = true
	_back_label.visible = false
	_guide_screen.visible = false
	_config_options.visible = false
	
	menu_options = $MenuOptions.get_children()
	_resume_opt.connect("selected", self, "_resume")
	_config_opt.connect("selected", self, "_toggle_config")
	_guide_opt.connect("selected", self, "_toggle_guide")
	_quit_opt.connect("selected", self, "_quit")


func _input(event):
	if not can_pause:
		return
	
	# Ignore input if unfocused, check for "back" input
	if unfocused:
		# Back from guide screen
		if _guide_screen.visible and event.is_action_released("attack_b"):
			_toggle_guide()
		
		if _config_options.visible and event.is_action_pressed("attack_b"):
			_toggle_config()
		
		return
	
	# Pause/unpause
	if event.is_action_pressed("esc"):
		if not get_tree().paused:
			if last_option_i != -1:
				menu_options[last_option_i].set_unselected()
			
			menu_options[0].set_selected()
			last_option_i = 0
			
			menu_paused = true
			get_tree().paused = true
			visible = true
			
			SoundsGlobal.play("ButtonPressed")
		elif menu_paused and get_tree().paused:
			menu_paused = false
			get_tree().paused = false
			visible = false
			
			SoundsGlobal.play("ButtonPressed")
	
	# Move up and down options while paused
	if menu_paused and get_tree().paused and event.is_action_pressed("move_up") \
			and event.get_action_strength("move_up") >= 1:
		menu_options[last_option_i].set_unselected()
		last_option_i -= 1
		
		if last_option_i < 0:
			last_option_i = menu_options.size() - 1
		
		menu_options[last_option_i].set_selected()
		
		SoundsGlobal.play("ButtonPressed")
	elif menu_paused and get_tree().paused and event.is_action_pressed("move_down") \
			and event.get_action_strength("move_down") >= 1:
		menu_options[last_option_i].set_unselected()
		last_option_i += 1
		
		if last_option_i > menu_options.size() - 1:
			last_option_i = 0
		
		menu_options[last_option_i].set_selected()
		
		SoundsGlobal.play("ButtonPressed")
	
	# Select option while paused
	if menu_paused and get_tree().paused and event.is_action_released("attack_a"):
		menu_options[last_option_i].trigger_selection()


# Unpause, for when button is pressed
func _resume():
	menu_paused = false
	get_tree().paused = false
	visible = false
	
	SoundsGlobal.play("ButtonPressed")


# Toggle config screen on/off
func _toggle_config():
	if _config_options.visible:
		unfocused = false
		_config_options.reset()
		_config_options.visible = false
		_menu_options.visible = true
		_confirm_label.visible = true
		_back_label.visible = false
	else:
		unfocused = true
		_config_options.visible = true
		_menu_options.visible = false
		_confirm_label.visible = false
		_back_label.visible = true
	
	SoundsGlobal.play("ButtonPressed")


# Toggle guide screen on/off
func _toggle_guide():
	if _guide_screen.visible:
		unfocused = false
		_guide_screen.visible = false
	else:
		unfocused = true
		_guide_screen.visible = true
	
	SoundsGlobal.play("ButtonPressed")


# Go to scene as specified by the quit_to_scene path
func _quit():
	unfocused = true
	
	# Quit game if no quit scene, else go to scene
	if quit_to_scene.empty():
		get_tree().quit()
	else:
		SoundsGlobal.play("ButtonPressed")
		
		_fade.go_to_scene(quit_to_scene)
