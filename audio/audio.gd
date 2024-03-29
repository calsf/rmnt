extends AudioStreamPlayer

# The minimum volume_db which is -80
const MIN_VOL = 80

export var default_vol := 0


# Sets vol and plays audio
func play_with_vol(vol_percent : float) -> void:
	set_vol(vol_percent)
	play()


# Sets audio volume_db based on volume percent and default vol
# vol_percent should be value between 0.0 - 1.0 (inclusive)
func set_vol(vol_percent : float) -> void:
	if vol_percent == 0.0: # 0.0 means mute, can just set to min vol
		volume_db = -MIN_VOL
	else:
		# Volume from minimum to add based on default starting vol and provided vol_percent
		var vol_added = ((MIN_VOL + default_vol) * vol_percent)
		
		volume_db = 0 - (MIN_VOL - vol_added)
