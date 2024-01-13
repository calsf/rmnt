extends CanvasLayer

# Path to the scene to quit to, set from parent HUD
export var quit_to_scene : String

const MAX_HEALTH_SIZE = 44.0
const MAX_METER_SIZE = 44.0

onready var enemy_bar = load("res://stages/hud/EnemyBar.tscn")
onready var player_icon = $PlayerBar/Icon
onready var health_fill = $PlayerBar/HealthFill
onready var health_anim = $PlayerBar/HealthFill/AnimationPlayer
onready var meter_fill = $PlayerBar/MeterFill
onready var meter_anim = $PlayerBar/MeterFill/AnimationPlayer
onready var enemy_bars = $EnemyBarContainer
onready var pause_menu = $PauseMenu

var curr_player_bar : Player


func _ready():
	pause_menu.quit_to_scene = quit_to_scene


# Init player bar, is called by player after player has been initialized
func init_player_bar(player : Player) -> void:
	curr_player_bar = player
	player.connect("health_updated", self, "_update_player_health")
	player.connect("meter_gained", self, "_update_player_meter")
	player_icon.texture = load(player.props.hud_icon_path)


# For main stage, sets player bar to display current player info
# Requires all players to have init and connected signals to hud
func set_as_player_bar(player : Player) -> void:
	curr_player_bar = player
	player_icon.texture = load(player.props.hud_icon_path)


# Add new enemy bar to container
func init_enemy_bar(enemy : Enemy) -> void:
	if enemy_bars.get_child_count() >= Global.MAX_ACTIVE_ENEMIES:
		return
	
	var bar = enemy_bar.instance()
	enemy_bars.add_child(bar)
	bar.init_enemy_hud(enemy)


# Update player health bar
func _update_player_health(player : Player) -> void:
	# Only update if is the current player to display
	if player != curr_player_bar:
		return
	
	var health_ratio = MAX_HEALTH_SIZE / player.props.max_hp
	health_fill.rect_size.x = min(MAX_HEALTH_SIZE, player.curr_hp * health_ratio)
	
	# Skip flash anim if full hp
	if player.curr_hp == player.props.max_hp:
		return
	
	health_anim.play("Flash")


# Update player meter bar
func _update_player_meter(player : Player) -> void:
	# Only update if is the current player to display
	if player != curr_player_bar:
		return
	
	var meter_ratio = MAX_METER_SIZE / player.props.max_meter
	meter_fill.rect_size.x = min(MAX_METER_SIZE, player.curr_meter * meter_ratio)
	
	if player.curr_meter == player.props.max_meter:
		meter_anim.play("Full")
	else:
		meter_anim.play("Flash")

