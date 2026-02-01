extends CanvasLayer

@onready var main_menu := %MainMenu
@onready var options_menu := %OptionsMenu
@onready var quit_menu := %QuitMenu

@onready var current_submenu := main_menu

var screen_resolutions: Dictionary[String, int] = {
	"3840x2160": 2160,
	"2560x1440": 1440,
	"1920x1200": 1200,
	"1920x1080": 1080,
	"1680x1050": 1050,
	"1440x900": 900,
	"1280x800": 800,
	"1024x768": 768,
	"1280x720": 720,
	"800x600": 600,
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_visibility()
	init_resolution_values()
	init_settings_values()
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

# Maybe unnecessary. Intended to catch cases where OS (ahem, Mac) changes fullscreen status.
# On Mac, doesn't seem to trigger on what I'd consider window mode changes.
#func _on_window_mode_changed(mode: DisplayServer.WindowMode):
	#%FullscreenCheckBox.pressed = (mode == DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)

func init_visibility() -> void:
	hide()
	main_menu.show()
	options_menu.hide()
	quit_menu.hide()

func init_resolution_values() -> void:
	for res_name in screen_resolutions:
		#var res_as_array := res_name.split("x")
		#screen_resolutions[res_name] = Vector2(
			#float(res_as_array[0]),
			#float(res_as_array[1])
			#)
		%ResolutionDropdown.add_item(res_name, screen_resolutions[res_name])

func init_settings_values() -> void:
	%MasterSlider.value = Settings.volume_master
	%MusicSlider.value = Settings.volume_music
	%SoundsSlider.value = Settings.volume_sounds
	%VoiceSlider.value = Settings.volume_voice
	%FullscreenCheckBox.button_pressed = Settings.fullscreen_enabled
	var res_id := screen_resolutions[Settings.screen_resolution]
	var res_idx: int = %ResolutionDropdown.get_item_index(res_id)
	%ResolutionDropdown.select(res_idx)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		if current_submenu == main_menu:
			unpause()
		elif current_submenu in [options_menu, quit_menu]:
			navigate(main_menu)

func navigate(submenu: Node) -> void:
	current_submenu.hide()
	current_submenu = submenu
	submenu.show()

func unpause() -> void:
	init_visibility()
	current_submenu = main_menu
	get_tree().paused = false

func _on_resume_button_pressed() -> void:
	unpause()

func _on_options_button_pressed() -> void:
	navigate(options_menu)

func _on_quit_button_pressed() -> void:
	navigate(quit_menu)

func _on_options_cancel_pressed() -> void:
	# Todo: prompt user whether to discard changes, if there are any
	navigate(main_menu)

func _on_options_confirm_pressed() -> void:
	apply_settings()
	# Todo: confirmation sound.
	navigate(main_menu)

func apply_settings() -> void:
	Settings.volume_master = %MasterSlider.value
	Settings.volume_music = %MusicSlider.value
	Settings.volume_sounds = %SoundsSlider.value
	Settings.volume_voice = %VoiceSlider.value
	
	var res_id: int = %ResolutionDropdown.get_item_id(%ResolutionDropdown.selected)
	Settings.screen_resolution = screen_resolutions.find_key(res_id)
	Settings.fullscreen_enabled = %FullscreenCheckBox.button_pressed
	
	Settings.save_and_apply()

signal went_to_title
func _on_quit_to_title_button_pressed() -> void:
	unpause()
	went_to_title.emit()

func _on_quit_to_desktop_button_pressed() -> void:
	get_tree().quit()

func _on_quit_back_button_pressed() -> void:
	navigate(main_menu)
