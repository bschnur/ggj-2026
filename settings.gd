extends Node

const SETTINGS_FILE_PATH := "user://settings.cfg"
var config := ConfigFile.new()

enum AudioBus {
	MASTER,
	MUSIC,
	SOUNDS,
	VOICE,
}

var bus_volumes := {
	AudioBus.MASTER: 0.5,
	AudioBus.MUSIC: 1.0,
	AudioBus.SOUNDS: 1.0,
	AudioBus.VOICE: 1.0,
}

var bus_to_setting_name_map := {
	AudioBus.MASTER: "volume_master",
	AudioBus.MUSIC: "volume_music",
	AudioBus.SOUNDS: "volume_sounds",
	AudioBus.VOICE: "volume_voice",
}

var bus_to_bus_name_map := {
	AudioBus.MASTER: "Master",
	AudioBus.MUSIC: "Music",
	AudioBus.SOUNDS: "Sounds",
	AudioBus.VOICE: "Voice",
}

var fullscreen_enabled := true
var screen_resolution := "1920x1080"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_load_settings()
	_apply_settings()

func save_and_apply() -> void:
	_apply_settings()
	_save_settings()

func _load_settings() -> void:
	# Load settings from file (or defaults).
	var load_err := config.load(SETTINGS_FILE_PATH)
	match load_err:
		ERR_FILE_CANT_OPEN:
			print("Settings file not found; using defaults.")
			_save_settings()
		OK:
			for bus in bus_volumes:
				bus_volumes[bus] = config.get_value("audio", bus_to_setting_name_map[bus], bus_volumes[bus])
			
			fullscreen_enabled = config.get_value("display", "fullscreen_enabled", fullscreen_enabled)
			screen_resolution = config.get_value("display", "screen_resolution", screen_resolution)

func write_audio_settings_to_config(conf: ConfigFile) -> void:
	for bus in bus_volumes:
		write_bus_volume_to_config(conf, bus)

func write_bus_volume_to_config(conf: ConfigFile, bus: AudioBus) -> void:
	conf.set_value("audio", bus_to_setting_name_map[bus], bus_volumes[bus])

func write_display_settings_to_config(conf: ConfigFile) -> void:
	conf.set_value("display", "fullscreen_enabled", fullscreen_enabled)
	conf.set_value("display", "screen_resolution", screen_resolution)

func _save_settings() -> void:
	write_audio_settings_to_config(config)
	write_display_settings_to_config(config)
	if OK == config.save(SETTINGS_FILE_PATH):
		print("Settings saved.")

func set_and_apply_audio_volume(bus: AudioBus, value: float) -> void:
	bus_volumes[bus] = value
	write_bus_volume_to_config(config, bus)
	apply_audio_bus_volume_setting(bus)

func apply_audio_bus_volume_setting(bus: AudioBus) -> void:
	var bus_idx := AudioServer.get_bus_index(bus_to_bus_name_map[bus])
	AudioServer.set_bus_volume_linear(bus_idx, bus_volumes[bus])

func apply_all_audio_volume_settings() -> void:
	for bus in bus_volumes:
		apply_audio_bus_volume_setting(bus)

func apply_display_settings() -> void:
	var fullscreen_actually_enabled = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	
	if fullscreen_enabled != fullscreen_actually_enabled:
		var new_fullscreen_mode: DisplayServer.WindowMode
		if fullscreen_actually_enabled:
			new_fullscreen_mode = DisplayServer.WINDOW_MODE_WINDOWED
		else:
			new_fullscreen_mode = DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(new_fullscreen_mode)
	
	var actual_screen_resolution := get_viewport().get_visible_rect().size
	
	var res_arr := screen_resolution.split("x")
	var res_vec := Vector2(float(res_arr[0]), float(res_arr[1]))
	
	if res_vec != actual_screen_resolution:
		get_window().content_scale_size = res_vec
		if not fullscreen_enabled:
			get_window().size = res_vec

func _apply_settings() -> void:
	apply_all_audio_volume_settings()
	apply_display_settings()
	
