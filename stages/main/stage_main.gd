extends Node2D

const DEFAULT_SHAKE_DECAY_RATE = 5.0
const DEFAULT_SHAKE_RANGE = 3
const DUMMY = "res://enemy/Dummy/Dummy.tscn"
const BS_FINAL = "res://enemy/BSFinal/BSFinal.tscn"

onready var _stage_bg = $WorldStaticBody/Background
onready var _stage_bg_end_anim = $WorldStaticBody/BackgroundEnd/AnimationPlayer
onready var _random = RandomNumberGenerator.new()

onready var rmnt_select = $CanvasLayer/RmntSelect
onready var stage_select_normal_ui = $CanvasLayer/StageSelectNormal
onready var stage_select_normal_interactable = $World/StageSelectNormal
onready var stage_select_endless_ui = $CanvasLayer/StageSelectEndless
onready var stage_select_endless_interactable = $World/StageSelectEndless
onready var swap_timer = $CanvasLayer/RmntSelect/Timer
onready var bs_final_interactable = $World/BSFinalInteractable

onready var _fade = get_tree().current_scene.get_node("HUD/Fade")
onready var players = get_tree().get_nodes_in_group("players")
onready var rmnts := [
	get_tree().current_scene.get_node("World/RM001"),
	get_tree().current_scene.get_node("World/RM002"),
	get_tree().current_scene.get_node("World/RM003"),
	get_tree().current_scene.get_node("World/RM004")
]

var is_in_lane := false
var is_overlapping_player_hurtbox := false
var is_bs_final_triggered := false

var shake_val := 0.0
var decay_rate := 0.0


func _ready():
	for i in range(rmnts.size()):
		rmnts[i].connect("died", self, "_on_player_death")
	
	SoundsGlobal.play("AmbienceStageMain")
	yield(get_tree().create_timer(.4), "timeout")
	MusicGlobal.play("Main")


func _input(event):
	# Avoid interaction once BSFinal is triggered
	if is_bs_final_triggered:
		return
	
	# Avoid interaction while mid swap
	if not swap_timer.is_stopped():
		return
	
	# BS Final interact trigger
	if bs_final_interactable.is_interactable:
		if event.is_action_pressed("interact"):
			trigger_bs_final()
			return
	
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
		
		SoundsGlobal.play("ButtonPressed")
		return
	
	# Endless stage select
	if event.is_action_released("attack_b") and stage_select_endless_ui.activated:
		for player in players:
			if player.visible:
				player.pause_player(false)
		
		stage_select_endless_ui.deactivate()
		rmnt_select.activate()
		stage_select_endless_interactable.set_can_interact(true)
		
		SoundsGlobal.play("ButtonPressed")
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
				
				SoundsGlobal.play("ButtonPressed")
	
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
				
				SoundsGlobal.play("ButtonPressed")


func _physics_process(delta):
	if not is_bs_final_triggered and get_tree().get_nodes_in_group("enemies").size() == 0:
		spawn_dummy()


func _process(delta):
	shake_val = lerp(shake_val, 0, decay_rate * delta)

	_stage_bg.offset = _get_random_offset()


# Spawn up to one dummy enemy
func spawn_dummy():
	if is_bs_final_triggered or get_tree().get_nodes_in_group("enemies").size() > 0:
		return
	
	var x = 160
	var y = 110
	
	var enemy = load(DUMMY).instance()
	enemy.global_position = Vector2(x, y)
	get_tree().current_scene.get_node("World").add_child(enemy)


# Triggers final boss
# Destroy dummy and prevent it from respawning
# Prevent interaction with stage selects
# Prevent swapping chars
func trigger_bs_final():
	is_bs_final_triggered = true
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.size() > 0:
		enemies[0].take_damage(enemies[0].curr_hp)
	
	rmnt_select.deactivate()
	stage_select_normal_interactable.set_can_interact(false)
	stage_select_endless_interactable.set_can_interact(false)
	bs_final_interactable.set_can_interact(false)
	
	shake(DEFAULT_SHAKE_RANGE, 1.25)
	
	# Spawn BSFinal
	var x = 160
	var y = 110
	
	var enemy = load(BS_FINAL).instance()
	enemy.global_position = Vector2(x, y)
	get_tree().current_scene.get_node("World").add_child(enemy)
	
	MusicGlobal.play("BS")


func _on_player_death(rmnt : Player):
	if get_tree().current_scene.has_node("World/DeathOverlay"):
		# Temporarily process sounds while paused
		SoundsGlobal.pause_mode = Node.PAUSE_MODE_PROCESS
		SoundsGlobal.stop_all()
		SoundsGlobal.play("RmntDeath")
		
		# Pause entire tree
		get_tree().paused = true
		
		# Only process death overlay, active player, and fade
		var death_overlay = get_tree().current_scene.get_node("World/DeathOverlay")
		death_overlay.pause_mode = Node.PAUSE_MODE_PROCESS
		rmnt.pause_mode = Node.PAUSE_MODE_PROCESS
		_fade.pause_mode = Node.PAUSE_MODE_PROCESS
		
		death_overlay.visible = true
		rmnt.z_index = death_overlay.z_index + 1
		
		# Wait for death anim to finish and return to main stage
		yield(rmnt.anim, "animation_finished")
		yield(get_tree().create_timer(.8, true), "timeout")
		
		# Revert pause mode
		SoundsGlobal.pause_mode = Node.PAUSE_MODE_INHERIT
		
		_fade.go_to_scene("res://title/Title.tscn")


# Call to shake the stage background
func shake(shake_range := DEFAULT_SHAKE_RANGE, shake_decay_rate := DEFAULT_SHAKE_DECAY_RATE):
	shake_val = shake_range
	decay_rate = shake_decay_rate


# Only shakes vertically
func _get_random_offset():
	if shake_val == 0:
		return Vector2.ZERO
	else:
		_random.randomize()
		var y = _random.randf_range(-shake_val, shake_val)
		return Vector2(0, y)


func trigger_end():
	MusicGlobal.stop_all()
	
	MusicGlobal.play("MainEnd")
	get_tree().current_scene.get_node("HUD/PauseMenu").can_pause = false
	get_tree().current_scene.get_node("HUD/PlayerBar").visible = false
	Engine.time_scale = .5
	_stage_bg_end_anim.play("Start")


func free_world():
	Engine.time_scale = 1
	$World.queue_free()
