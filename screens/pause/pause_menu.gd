extends CanvasLayer

@onready var main_menu := %MainMenu
@onready var options_menu := %OptionsMenu
@onready var credits := %Credits
@onready var quit_menu := %QuitMenu

@onready var current_submenu := main_menu

@onready var resolution_dropdown := %ResolutionDropdown
@onready var fullscreen_check_box := %FullscreenCheckBox

@onready var master_slider := %MasterSlider
@onready var music_slider := %MusicSlider
@onready var sounds_slider := %SoundsSlider
@onready var voice_slider := %VoiceSlider

@onready var slider_to_bus_map := {
	master_slider: Settings.AudioBus.MASTER,
	music_slider: Settings.AudioBus.MUSIC,
	sounds_slider: Settings.AudioBus.SOUNDS,
	voice_slider: Settings.AudioBus.VOICE,
}

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
	# TODO: connect to settings loaded signal; move all initialization based on Settings values/methods into the function subsequently called.
	Settings.settings_loaded.connect(init_settings_values)
	init_visibility()
	init_resolution_values()
	#init_settings_values()
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func init_visibility() -> void:
	hide()
	main_menu.show()
	options_menu.hide()
	credits.hide()
	quit_menu.hide()

func init_resolution_values() -> void:
	resolution_dropdown.clear()
	for res_name in screen_resolutions:
		resolution_dropdown.add_item(res_name, screen_resolutions[res_name])

func init_settings_values() -> void:
	master_slider.value = Settings.bus_volumes[Settings.AudioBus.MASTER]
	music_slider.value = Settings.bus_volumes[Settings.AudioBus.MUSIC]
	sounds_slider.value = Settings.bus_volumes[Settings.AudioBus.SOUNDS]
	voice_slider.value = Settings.bus_volumes[Settings.AudioBus.VOICE]
	
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
	window_drag_block_should_clear.emit()
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

func get_selected_resolution() -> Vector2i:
	var res_id: int = resolution_dropdown.get_item_id(resolution_dropdown.selected)
	var res_arr = screen_resolutions.find_key(res_id).split("x")
	return Vector2i(int(res_arr[0]), int(res_arr[1]))

func get_fullscreen_state() -> bool:
	return fullscreen_check_box.button_pressed

func set_display_settings() -> void:
	var res_id: int = resolution_dropdown.get_item_id(resolution_dropdown.selected)
	Settings.screen_resolution = screen_resolutions.find_key(res_id)
	Settings.fullscreen_enabled = get_fullscreen_state()

func save_all_settings() -> void:
	Settings.save_and_apply()

signal went_to_title
func _on_quit_to_title_button_pressed() -> void:
	unpause()
	went_to_title.emit()

func _on_quit_to_desktop_button_pressed() -> void:
	get_tree().quit()

func _on_quit_back_button_pressed() -> void:
	navigate(main_menu)


func _on_credits_button_pressed() -> void:
	navigate(credits)


func _on_credits_back_button_pressed() -> void:
	navigate(main_menu)

signal toggled_resolution_dropdown(toggled_on: bool)

func _on_resolution_dropdown_toggled(toggled_on: bool) -> void:
	toggled_resolution_dropdown.emit(toggled_on)

signal boop_required
func _on_options_confirm_pressed() -> void:
	set_display_settings()
	save_all_settings()
	# Play confirmation sound (handled by main.gd).
	boop_required.emit()
	navigate(main_menu)

signal window_drag_block_should_increment
func _on_slider_mouse_enter_or_drag_start() -> void:
	window_drag_block_should_increment.emit()

signal window_drag_block_should_decrement
func _on_slider_mouse_exit() -> void:
	window_drag_block_should_decrement.emit()

signal window_drag_block_should_clear
func _on_slider_drag_ended(_value_changed: bool, slider: Slider) -> void:
	#if value_changed:
		# TODO: This might be better connected to value_changed.
		#Settings.set_and_apply_audio_volume(slider_to_bus_map[slider], slider.value)
	if slider == sounds_slider:
		boop_required.emit()
	
	# Window drag blocking reference count signal propagation.
	if get_viewport().get_visible_rect().has_point(get_viewport().get_mouse_position()):
		window_drag_block_should_decrement.emit()
	else:
		# As a safety check for some edge cases:
		# If the cursor is outside window bounds when slider drag ends,
		# clear the reference counter (handled by signal processor i.e. main.gd).
		window_drag_block_should_clear.emit()

var volume_change_application_allowed := true
const VOLUME_CHANGE_DEBOUNCE_DELAY := 0.1
func _on_slider_value_changed(value: float, slider: Slider) -> void:
	if volume_change_application_allowed:
		Settings.set_and_apply_audio_volume(slider_to_bus_map[slider], value)
		volume_change_application_allowed = false
		get_tree().create_timer(VOLUME_CHANGE_DEBOUNCE_DELAY).connect(
			"timeout",
			func():volume_change_application_allowed = true
			)
