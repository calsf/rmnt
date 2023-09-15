extends Node2D

onready var rmnt_select = $CanvasLayer/RmntSelect
onready var stage_select_mob_ui = $CanvasLayer/StageSelectMob
onready var stage_select_mob_interactable = $World/StageSelectMob

onready var players = get_tree().get_nodes_in_group("players")

var is_in_lane := false
var is_overlapping_player_hurtbox := false


func _input(event):
	# Toggle stage select off if activated
	# May be triggered outside the interactable area so we need to be able to handle separately
	if event.is_action_pressed("interact") and stage_select_mob_ui.activated:
		for player in players:
			if player.visible:
				player.pause_player(false)
		
		stage_select_mob_ui.deactivate()
		rmnt_select.activate()
		stage_select_mob_interactable.set_can_interact(true)
		return
	
	# If in interactable area for stage select
	if stage_select_mob_interactable.is_interactable:
		if event.is_action_pressed("interact"):
			if not stage_select_mob_ui.activated:
				for player in players:
					if player.visible:
						player.pause_player(true)
				
				stage_select_mob_ui.activate()
				rmnt_select.deactivate()
				stage_select_mob_interactable.set_can_interact(false)
