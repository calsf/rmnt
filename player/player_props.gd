extends Resource
class_name PlayerProps

export var max_hp : int
export var speed_x : float
export var speed_y : float
export var speed_x_dash : float
export var speed_y_dash : float
export var ground_decel := 200 # Knockback decel
export var hitstun_multiplier := 1.0 # Default 1.0, multiplies base knockback
export var air_hitstun_multiplier := 1.0 # Default 1.0, multiplies base knockup/knockdown
