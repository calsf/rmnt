extends Sprite

onready var original_char_sprite = get_parent().get_node("CharSprite")


func _ready():
	pass


func _process(delta):
	texture = original_char_sprite.texture
	hframes = original_char_sprite.hframes
	frame = original_char_sprite.frame
