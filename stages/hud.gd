extends CanvasLayer

const MAX_HEALTH_SIZE = 44.0

onready var player_icon = $PlayerBar/Icon
onready var health_fill = $PlayerBar/HealthFill


# Init player bar, is called by player after player has been initialized
func init_player_bar(player : Player) -> void:
	player.connect("health_updated", self, "_update_health")
	player_icon.texture = load(player.props.hud_icon_path)


func _update_health(player : Player) -> void:
	var health_ratio = MAX_HEALTH_SIZE / player.props.max_hp
	health_fill.rect_size.x = min(MAX_HEALTH_SIZE, player.curr_hp * health_ratio)

