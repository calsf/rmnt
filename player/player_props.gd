extends Resource
class_name PlayerProps

# Y speed should be 70% of X speed

export var max_hp := 100
export var max_meter := 100
export var speed_x : float
export var speed_y : float
export var speed_x_dash : float
export var speed_y_dash : float
export var ground_decel := 200 # Knockback decel
export var hitstun_multiplier := 1.0 # Default 1.0, multiplies base knockback
export var air_hitstun_multiplier := 1.0 # Default 1.0, multiplies base knockup/knockdown
export var hud_icon_path : String
export var hitsparks_path := "res://player/PlayerHitsparks.tscn"
