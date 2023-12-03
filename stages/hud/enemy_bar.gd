extends Control
class_name EnemyBar

const MAX_HEALTH_SIZE = 44

onready var icon = $Icon
onready var health_fill = $HealthFill
onready var anim = $AnimationPlayer


# Init enemy hud
func init_enemy_hud(enemy : Enemy) -> void:
	enemy.connect("health_updated", self, "_update_health")
	enemy.connect("died", self, "_on_death")
	
	icon.texture = load(enemy.props.hud_icon_path)


func _update_health(enemy : Enemy) -> void:
	var health_ratio = MAX_HEALTH_SIZE / enemy.props.max_hp
	health_fill.rect_size.x = min(MAX_HEALTH_SIZE, enemy.curr_hp * health_ratio)
	
	# Skip flash anim if full hp
	if enemy.curr_hp == enemy.props.max_hp:
		return
	
	anim.play("Flash")


func _on_death(enemy : Enemy) -> void:
	queue_free()
