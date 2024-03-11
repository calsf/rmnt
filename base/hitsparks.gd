extends Node2D

onready var particles = $Particles2D

var done := false


func _ready():
	particles.emitting = true


func _process(delta):
	if not done and not particles.emitting:
		done = true
		queue_free()
