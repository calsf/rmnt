extends StageSelect


func _ready():
	stages = [
		"res://stages/StageEndless001.tscn",
		"res://stages/main/StageMain.tscn",
		"res://stages/main/StageMain.tscn",
	]
	
	stage_icons = [
		load("res://stages/Stage001-Select.png"),
		load("res://stages/StageLocked.png"),
		load("res://stages/StageLocked.png")
	]
	
	var stage_unlocks = SaveLoadManager.get_endless_stage_unlocks()
	for i in range(0, stage_icons.size()):
		if not stage_unlocks[i]:
			stage_icons[i] = load("res://stages/StageLocked.png")
	
	initialize_stage_select()


func _select_stage(selected_index : int):
	preview.texture = stage_icons[selected_index]
	# Iterate through each stage option
	for i in range(min_stage_i, max_stage_i + 1):
		if i == selected_index:
			select_icons[i].texture = selected_icon
		else:
			select_icons[i].texture = unselected_icon
	
	# Also update kill count label
	var stage_scores = SaveLoadManager.get_endless_stage_scores()
	var stage_unlocks = SaveLoadManager.get_endless_stage_unlocks()
	
	var kill_count_label = $KillCount/Label
	if stage_unlocks[curr_stage_i]:
		kill_count_label.text = str(stage_scores[curr_stage_i])
	else:
		kill_count_label.text = "???"


func validate() -> bool:
	var stage_unlocks = SaveLoadManager.get_endless_stage_unlocks()
	return stage_unlocks[curr_stage_i]
