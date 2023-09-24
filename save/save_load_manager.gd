# Save load manager singleton
extends Node

const SAVE_PATH = "user://sav.json"

# Default data to be saved with new save file
var _default_data := {
	"selected_rmnt_i" : 0
}

# Data loaded from save
var loaded_data := {}


# Get save data
func _init():
	loaded_data = _load_data()


# Save and overwrite save file with data arg or current loaded_data by default
func save_data(data := loaded_data):
	# Create and open file
	var save_file = File.new()
	save_file.open_encrypted_with_pass(SAVE_PATH, File.WRITE, "")
	
	# Convert data to json, store, and close file
	save_file.store_line(to_json(data))
	save_file.close()


func _load_data():
	# If no file to load from, first create save file with default values
	var save_file = File.new()
	if not save_file.file_exists(SAVE_PATH):
		save_data(_default_data)
		
	# Open file
	save_file.open_encrypted_with_pass(SAVE_PATH, File.READ, "")

	# Parse data then close file
	var data = parse_json(save_file.get_as_text())
	save_file.close()

	return data


# Used to get current data, sets and saves data if requested data doesn't exist but should
func get_save_data(key : String):
	# If data is not in save but should exist as part of default data, set to default
	# Also saves the current data
	if not loaded_data.has(key) and _default_data.has(key):
		loaded_data[key] = _default_data[key]
		save_data()
	
	return loaded_data[key]


# Sets data value
# DOES NOT SAVE DATA
func set_save_data(key : String, val):
	loaded_data[key] = val


# Reset data
func reset_data():
	save_data(_default_data)


# Check if save file exists
func check_save():
	var dir = Directory.new()
	var save = dir.file_exists(SAVE_PATH)
	return save
