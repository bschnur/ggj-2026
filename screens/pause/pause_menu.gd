extends CanvasLayer

@onready var main_menu := %MainMenu
@onready var options_menu := %OptionsMenu
@onready var quit_menu := %QuitMenu

@onready var current_submenu := main_menu

@onready var resolution_dropdown := %ResolutionDropdown
@onready var fullscreen_check_box := %FullscreenCheckBox
@onready var master_slider := %MasterSlider
@onready var music_slider := %MusicSlider
@onready var sounds_slider := %SoundsSlider
@onready var voice_slider := %VoiceSlider

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

func init_visibility() -> void:
	hide()
	main_menu.show()
	options_menu.hide()
	quit_menu.hide()

func init_resolution_values() -> void:
	resolution_dropdown.clear()
	for res_name in screen_resolutions:
		resolution_dropdown.add_item(res_name, screen_resolutions[res_name])

func init_settings_values() -> void:
	master_slider.value = Settings.volume_master
	music_slider.value = Settings.volume_music
	sounds_slider.value = Settings.volume_sounds
	voice_slider.value = Settings.volume_voice
	fullscreen_check_box.button_pressed = Settings.fullscreen_enabled
	var res_id := screen_resolutions[Settings.screen_resolution]
	var res_idx: int = resolution_dropdown.get_item_index(res_id)
	resolution_dropdown.select(res_idx)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		if current_submenu == main_menu:
			unpause()
		elif current_submenu in [options_menu, quit_menu]:
			navigate(main_menu)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		%SubViewportContainer2.update_mouse_pos()
		# The mouse position within the 0 to size.x/y range of THIS viewport.
		# It is the "canonical" coordinate for FRAGCOORD.
		var mouse_pos := (event as InputEventMouseMotion).position
		# Update the position of the software mouse.
		%SoftwareMouse.position = mouse_pos

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
	Settings.volume_master = master_slider.value
	Settings.volume_music = music_slider.value
	Settings.volume_sounds = sounds_slider.value
	Settings.volume_voice = voice_slider.value
	
	var res_id: int = resolution_dropdown.get_item_id(resolution_dropdown.selected)
	Settings.screen_resolution = screen_resolutions.find_key(res_id)
	Settings.fullscreen_enabled = fullscreen_check_box.button_pressed
	
	Settings.save_and_apply()

signal went_to_title
func _on_quit_to_title_button_pressed() -> void:
	unpause()
	went_to_title.emit()

func _on_quit_to_desktop_button_pressed() -> void:
	get_tree().quit()

func _on_quit_back_button_pressed() -> void:
	navigate(main_menu)
