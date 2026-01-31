extends Node

const SETTINGS_FILE_PATH := "user://settings.cfg"
var config := ConfigFile.new()

var volume_master := 0.5
var volume_music := 0.5
var volume_sounds := 0.5
var volume_voice := 0.5

var fullscreen_enabled := true
var screen_resolution := "1920x1080"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_settings()

func load_settings() -> void:
	# Load settings from file (or defaults).
	var load_err := config.load(SETTINGS_FILE_PATH)
	match load_err:
		ERR_FILE_CANT_OPEN:
			print("Settings file not found; using defaults.")
			save_settings()
		OK:
			volume_master = config.get_value("audio", "volume_master", volume_master)
			volume_music = config.get_value("audio", "volume_music", volume_music)
			volume_sounds = config.get_value("audio", "volume_sounds", volume_sounds)
			volume_voice = config.get_value("audio", "volume_voice", volume_voice)
			
			fullscreen_enabled = config.get_value("display", "fullscreen_enabled", fullscreen_enabled)
			screen_resolution = config.get_value("display", "screen_resolution", screen_resolution)
	# Apply settings.
	var bus_volumes := {
		"Master": volume_master,
		"Music": volume_music,
		"Sounds": volume_sounds,
		"Voice": volume_voice,
	}
	for bus_name in bus_volumes:
		var bus_idx := AudioServer.get_bus_index(bus_name)
		AudioServer.set_bus_volume_linear(bus_idx, bus_volumes[bus_name])
	

func save_settings() -> void:
	config.set_value("audio", "volume_master", volume_master)
	config.set_value("audio", "volume_music", volume_music)
	config.set_value("audio", "volume_sounds", volume_sounds)
	config.set_value("audio", "volume_voice", volume_voice)
	
	config.set_value("display", "fullscreen_enabled", fullscreen_enabled)
	config.set_value("display", "screen_resolution", screen_resolution)
	
	if OK == config.save(SETTINGS_FILE_PATH):
		print("Settings saved.")
