class_name EnemyState
extends State

# Enemy reference
var enemy: Enemy


func _ready() -> void:
	# States should be children of Enemy -> StateMachine
	# Wait for owner/Enemy node to be ready before State
	yield(owner, "ready")
	
	# Cast owner to Enemy type
	enemy = owner as Enemy
	assert(enemy != null)
