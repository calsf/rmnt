extends Node2D

onready var rmnt_select = $CanvasLayer/RmntSelect
onready var stage_select = $CanvasLayer/StageSelect
onready var stage_select_area = $World/StageSelectArea
onready var players = get_tree().get_nodes_in_group("players")


func _input(event):
	# Toggle stage select off if activated
	# May be triggered outside the interactable area so we need to be able to handle separately
	if event.is_action_pressed("interact") and stage_select.activated:
		for player in players:
			if player.visible:
				player.pause_player(false)
		
		stage_select.deactivate()
		rmnt_select.activate()
		return
	
	# If in interactable area for stage select
	var areas = stage_select_area.get_overlapping_areas()
	if areas:
		if event.is_action_pressed("interact"):
			if not stage_select.activated:
				for player in players:
					if player.visible:
						player.pause_player(true)
				
				stage_select.activate()
				rmnt_select.deactivate()
