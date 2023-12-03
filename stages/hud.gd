extends CanvasLayer

const MAX_HEALTH_SIZE = 44.0

onready var enemy_bar = load("res://stages/hud/EnemyBar.tscn")
onready var player_icon = $PlayerBar/Icon
onready var health_fill = $PlayerBar/HealthFill
onready var health_anim = $PlayerBar/HealthFill/AnimationPlayer
onready var enemy_bars = $EnemyBarContainer


# Init player bar, is called by player after player has been initialized
func init_player_bar(player : Player) -> void:
	player.connect("health_updated", self, "_update_player_health")
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
	var health_ratio = MAX_HEALTH_SIZE / player.props.max_hp
	health_fill.rect_size.x = min(MAX_HEALTH_SIZE, player.curr_hp * health_ratio)
	
	# Skip flash anim if full hp
	if player.curr_hp == player.props.max_hp:
		return
	
	health_anim.play("Flash")

