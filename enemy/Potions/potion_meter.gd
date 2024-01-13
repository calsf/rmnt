# Extends Enemy but will not be included in enemies group or in hud
# NOTE: GroundDetection should be disabled to avoid other enemies colliding with it
# NOTE: Hitstun states should be replaced with Idle state behavior
extends Enemy


# Remove self from group
func _init():
	remove_from_group("enemies")


# Overrides base Enemy to avoid adding to hud
# Connect and initialize hud for this enemy
# To be called by enemy itself after initializing
func init_hud():
	pass


func take_damage(dmg : float) -> void:
	curr_hp -= dmg
	emit_signal("health_updated", self)
	
	# Death check
	if curr_hp <= 0:
		# Instance death effect before removing enemy
		var death = load(props.death_path).instance()
		get_tree().current_scene.get_node("World").add_child(death)
		death.global_position = enemy_child.global_position
		emit_signal("died", self)
		
		# Gain player meter on death
		var player = get_player_target()
		player.gain_meter(player.props.max_meter)
		
		queue_free()
