extends Node2D

onready var rmnt_select = $CanvasLayer/RmntSelect
onready var stage_select_normal_ui = $CanvasLayer/StageSelectNormal
onready var stage_select_normal_interactable = $World/StageSelectNormal
onready var stage_select_endless_ui = $CanvasLayer/StageSelectEndless
onready var stage_select_endless_interactable = $World/StageSelectEndless

onready var players = get_tree().get_nodes_in_group("players")

var is_in_lane := false
var is_overlapping_player_hurtbox := false


func _input(event):
	# Toggle UIs off if activated
	# May be triggered outside the interactable area so we need to be able to handle separately
	# Normal stage select
	if event.is_action_released("attack_b") and stage_select_normal_ui.activated:
		for player in players:
			if player.visible:
				player.pause_player(false)
		
		stage_select_normal_ui.deactivate()
		rmnt_select.activate()
		stage_select_normal_interactable.set_can_interact(true)
		return
	
	# Endless stage select
	if event.is_action_released("attack_b") and stage_select_endless_ui.activated:
		for player in players:
			if player.visible:
				player.pause_player(false)
		
		stage_select_endless_ui.deactivate()
		rmnt_select.activate()
		stage_select_endless_interactable.set_can_interact(true)
		return
	
	# Toggle UIs on
	# Normal stage select
	if stage_select_normal_interactable.is_interactable:
		if event.is_action_pressed("interact"):
			if not stage_select_normal_ui.activated:
				for player in players:
					if player.visible:
						player.pause_player(true)
				
				stage_select_normal_ui.activate()
				rmnt_select.deactivate()
				stage_select_normal_interactable.set_can_interact(false)
	
	# Endless stage select
	if stage_select_endless_interactable.is_interactable:
		if event.is_action_pressed("interact"):
			if not stage_select_endless_ui.activated:
				for player in players:
					if player.visible:
						player.pause_player(true)
				
				stage_select_endless_ui.activate()
				rmnt_select.deactivate()
				stage_select_endless_interactable.set_can_interact(false)
