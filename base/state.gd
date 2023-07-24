# Base State
class_name State
extends Node

# State machine reference
var state_machine = null


# Virtual function for `_unhandled_input()` callback
func handle_input(event: InputEvent) -> void:
	pass


# Virtual function for  `_process()` callback.
func state_process(delta: float) -> void:
	pass


# Virtual function for `_physics_process()` callback
func state_physics_process(delta: float) -> void:
	pass


# Virtual function for entering a state
# Should be called by the state machine when entering state
# `data_state` parameter is a dictionary of additional data that may be used
func enter(data_state := {}) -> void:
	pass


# Virtual function for exiting a state
# Should be called by the state machine when leaving state
# `data_state` parameter is a dictionary of additional data that may be used
func exit(data_state := {}) -> void:
	pass


