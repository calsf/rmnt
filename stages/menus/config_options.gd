extends VBoxContainer

var config_options := []
var last_option_i := -1


func _ready():
	config_options = get_children()
	reset()


func reset():
	# Init to first option
	for i in range(0, config_options.size()):
		if i == 0:
			config_options[i].set_selected()
			last_option_i = i
		else:
			config_options[i].set_unselected()


func _input(event):
	# Move up and down options while visible
	# Also listen for decrease/increase on selected option
	if visible and event.is_action_pressed("move_up") \
			and event.get_action_strength("move_up") >= 1:
		config_options[last_option_i].set_unselected()
		last_option_i -= 1
		
		if last_option_i < 0:
			last_option_i = config_options.size() - 1
		
		config_options[last_option_i].set_selected()
		
		SoundsGlobal.play("ButtonPressed")
	elif visible and event.is_action_pressed("move_down") \
			and event.get_action_strength("move_down") >= 1:
		config_options[last_option_i].set_unselected()
		last_option_i += 1
		
		if last_option_i > config_options.size() - 1:
			last_option_i = 0
		
		config_options[last_option_i].set_selected()
		
		SoundsGlobal.play("ButtonPressed")
	elif visible and event.is_action_pressed("prev"):
		config_options[last_option_i].decrease()
	elif visible and event.is_action_pressed("next"):
		config_options[last_option_i].increase()
