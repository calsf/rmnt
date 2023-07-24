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
