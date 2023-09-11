extends Node2D

onready var rmnt_select = $CanvasLayer/RmntSelect
onready var mob_stage_select = $CanvasLayer/MobStageSelect
onready var mob_stage_select_area = $World/MobStageSelectArea
onready var mob_stage_select_area_interact_label = $World/MobStageSelectArea/InteractLabel
onready var players = get_tree().get_nodes_in_group("players")

var is_in_lane := false
var is_overlapping_player_hurtbox := false

func _process(delta):
	# If in interactable area for stage select
	var areas = mob_stage_select_area.get_overlapping_areas()
	is_in_lane = false
	is_overlapping_player_hurtbox = false
	
	# Check areas for both lane detection and player hurtbox
	if areas:
		for area in areas:
			if area.collision_layer == 2:
				is_in_lane = true
			
			if area.collision_layer == 8:
				is_overlapping_player_hurtbox = true
	
	# Toggle interact label
	if is_overlapping_player_hurtbox and is_in_lane and not mob_stage_select.activated:
		mob_stage_select_area_interact_label.visible = true
	else:
		mob_stage_select_area_interact_label.visible = false
	

func _input(event):
	# Toggle stage select off if activated
	# May be triggered outside the interactable area so we need to be able to handle separately
	if event.is_action_pressed("interact") and mob_stage_select.activated:
		for player in players:
			if player.visible:
				player.pause_player(false)
		
		mob_stage_select.deactivate()
		rmnt_select.activate()
		return
	
	# If in interactable area for stage select
	if is_overlapping_player_hurtbox and is_in_lane:
		if event.is_action_pressed("interact"):
			if not mob_stage_select.activated:
				for player in players:
					if player.visible:
						player.pause_player(true)
				
				mob_stage_select.activate()
				rmnt_select.deactivate()
				mob_stage_select_area_interact_label.visible = false
