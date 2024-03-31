extends Control

const MIN_VOL = 0
const MAX_VOL = 10

# The save_load_manager data setting key this option corresponds to
# e.g "music_vol" or "sound_vol"
export var config_key : String

onready var _left = $Left
onready var _right = $Right
onready var _bars = $Bars

var vol : int


func _ready():
	vol = SaveLoadManager.get_save_data(config_key)
	
	var bars = _bars.get_children()
	for i in range(0, bars.size()):
		if i <= vol - 1:
			bars[i].visible = true
		else:
			bars[i].visible = false


func set_selected() -> void:
	_left.visible = true
	_right.visible = true


func set_unselected() -> void:
	_left.visible = false
	_right.visible = false


func decrease() -> void:
	if vol <= MIN_VOL:
		return
	
	_bars.get_child(vol - 1).visible = false
	vol -= 1
	SaveLoadManager.set_save_data(config_key, vol)
	SaveLoadManager.save_data()
	
	SoundsGlobal.play("ButtonPressed")
	_update_audio_volumes(config_key)


func increase() -> void:
	if vol >= MAX_VOL:
		return
	
	vol += 1
	_bars.get_child(vol - 1).visible = true
	SaveLoadManager.set_save_data(config_key, vol)
	SaveLoadManager.save_data()
	
	SoundsGlobal.play("ButtonPressed")
	_update_audio_volumes(config_key)


func _update_audio_volumes(config_key : String) -> void:
	# Need to update corresponding audio players
	if config_key == "sound_vol":
		SoundsGlobal.update_all_audio_volumes()
	elif config_key == "music_vol":
		MusicGlobal.update_all_audio_volumes()
