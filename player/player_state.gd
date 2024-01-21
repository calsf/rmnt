class_name PlayerState
extends State

# Player reference
var player: Player


func _ready() -> void:
	# States should be children of Player -> StateMachine
	# Wait for owner/Player node to be ready before State
	yield(owner, "ready")
	
	# Cast owner to Player type
	player = owner as Player
	assert(player != null)


# Should be able to transition to attack special from any player state
func check_attack_special() -> bool:
	if player.visible and player.curr_meter == player.props.max_meter and Input.is_action_pressed("attack_special"):
		state_machine.transition_to("AttackSpecial")
		return true
	
	return false


func transition_to_dash() -> bool:
	if player.dash_timer.is_stopped():
		player.dash_timer.start()
		state_machine.transition_to("Dash")
		return true
	
	return false
