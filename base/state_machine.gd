# Base StateMachine
# Initialize states and delegate callbacks to the active state
class_name StateMachine
extends Node

# Signal for when state has changed
signal transitioned(state_name)

# Path to the initial state to set in editor
export var initial_state := NodePath()

# Current state
onready var curr_state: State = get_node(initial_state)


func _ready() -> void:
	yield(owner, "ready")
	# Children of the state machine should be all the states
	# Set state machine reference to this state machine for all states
	for child in get_children():
		child.state_machine = self
	
	# Enter initial state
	curr_state.enter()


# Delegates callbacks to the current state
func _unhandled_input(event: InputEvent) -> void:
	curr_state.handle_input(event)


func _process(delta: float) -> void:
	curr_state.state_process(delta)


func _physics_process(delta: float) -> void:
	curr_state.state_physics_process(delta)


# Leaves current state and enters target state name to transition to
# The target state name must match the Node name that is a child of this state machine
func transition_to(target_state_name: String, data_state: Dictionary = {}) -> void:
	# If no matching state name in child Nodes, simply return
	if not has_node(target_state_name):
		print("MISSING STATE: " + target_state_name)
		return
	
	curr_state.exit(data_state)
	curr_state = get_node(target_state_name)
	curr_state.enter(data_state)
	emit_signal("transitioned", curr_state.name)
