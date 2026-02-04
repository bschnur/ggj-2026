extends Node
class_name Main

# TODO:

# 1. Scale cursor based on window/viewport width/height (relevant todo below).
# 2. X Make window draggable when not in fullscreen.
# 2a. X Fixed: incorrect mouse mode state handling when lens color toggled during window drag.
# 2b. X Minor refactor to avoid direct reference to specific mouse modes in main logic.
# 2c. Add screen clamping. Account for multiple monitors and subsequent software mouse position. (Latter may take care of itself.)
# 3. Address the issue of low resolution keyhole syndrome
# 		(maybe involves minimum sizes, anchors, or stretch?).

var current_screen_scale := 1.0
# TODO: also store a scalar representing the current game scale compared to 1080p.
# This should be used to resize the mouse cursor images - and change the filter radius!
var os_screen_scale: float

@onready var title_screen := %TitleScreen
@onready var pause_menu := %PauseMenu
@onready var world := %World
@onready var win_screen := %WinScreen

@onready var software_mouse := %SoftwareMouse

@onready var world_blend_viewport := %SubViewportContainer2

var masks_remaining := 6

func _on_mask_location_clicked(btn: BaseButton, col: int) -> void:
	if col != filter_color:
		btn.set_deferred("disabled", true)
		_on_mask_found()

func _on_mask_found() -> void:
	masks_remaining -= 1
	play_boop()
	if masks_remaining == 0:
		# YOU WIN!
		masks_remaining = 6
		world_blend_viewport.reset_masks()
		nav_to_win_screen()

func play_boop():
	sound_player.play()

enum FilterColor {
	NONE = 0,
	RED = 1,
	BLUE = 2,
}

@export var filter_cursor_textures: Dictionary[FilterColor, Texture2D]
var _filter_cursor_images: Dictionary[FilterColor, Image]

var filter_color := FilterColor.NONE:
	set(value):
		# Todo: the below would probably be better to set on detected display DPI change - but *shrug* it's a 48h jam.
		if os_screen_scale != current_screen_scale:
			scale_cursor_images()
		
		if value != FilterColor.NONE:
			# Should stash prev mouse mode in drag, and if dragging, update that instead.
			if is_dragging_mouse:
				drag_stashed_mouse_mode = Settings.hide_os_mouse_mode
			else:
				Input.set_mouse_mode(Settings.hide_os_mouse_mode)
			
			var cursor_texture := filter_cursor_textures[value]
			var hotspot := cursor_texture.get_size() * 0.5
			set_software_mouse_cursor(cursor_texture, hotspot, true)
		else:
			Input.set_mouse_mode(Settings.show_os_mouse_mode)
			hide_software_mouse_cursor()
			#Input.set_custom_mouse_cursor(cursor_img, Input.CURSOR_ARROW, hotspot)
		
		RenderingServer.global_shader_parameter_set("mouse_lens_color_id", value)
		filter_color = value

var stashed_filter_color: FilterColor

func set_software_mouse_cursor(cursor_texture: Texture2D, hotspot: Vector2, show := true) -> void:
	#var shape := Input.CURSOR_ARROW
	software_mouse.texture = cursor_texture
	software_mouse.offset = -hotspot
	if show:
		show_software_mouse_cursor()

func show_software_mouse_cursor() -> void:
	software_mouse.show()

func hide_software_mouse_cursor() -> void:
	software_mouse.hide()

func _ready() -> void:
	# Disable focus mode on all buttons.
	# RIP accessibility but game is vision- and mouse-reliant anyhow.
	# (I don't want to handle mirrored alternative w/o in-editor support.)
	var all_buttons := find_children("*", "Button")
	for b in all_buttons:
		(b as Button).focus_mode = Control.FOCUS_NONE
	
	# Hack to stop scaling cursor by OS resolution scale: pretend the scale is 1.0.
	#os_screen_scale = DisplayServer.screen_get_max_scale()
	os_screen_scale = 1.0
	# This leaves the relevant code available to review for other projects/purposes,
	# without having to go find an older commit - and is a fast fix.
	
	init_cursor_images()
	scale_cursor_images()
	filter_color = FilterColor.RED
	play_current_music_track()
	nav_to_title()

const music_starts: Array[float] = [
	30.0,
	0.0,
]

const music_ends: Array[float] = [
	124.0,
	136.0,
]

const music_fade_in_time := 1.0
const music_fade_out_time := 4.0
const music_gap := 2.0

@onready var music_tracks := [
	preload("res://audio/cats and birds.wav"),
	preload("res://audio/music_zapsplat_game_music_mystery_underscore_airy_dark_tension_006.mp3"),
]

@onready var sounds := [
	preload("res://audio/pop-tap-click-fx-383733.mp3"),
]

@onready var music_player = %MusicPlayer
@onready var sound_player = %SoundPlayer

var current_music_track := 0

func fade_in():
	music_player.stream = music_tracks[current_music_track]
	music_player.volume_db = -80  # Start silent
	#music_player.call_deferred("play", music_starts[current_music_track])
	music_player.play(music_starts[current_music_track])
	var tween := create_tween()
	# Transition volume_db to 0 (normal volume) over the specified duration
	tween.tween_property(music_player, "volume_db", 0.0, music_fade_in_time).set_trans(Tween.TRANS_SINE)

func fade_out_before_end():
	# 1. Calculate how long to wait before starting the fade
	var current_pos = music_player.get_playback_position()
	var time_until_fade = (music_ends[current_music_track] - current_pos) - music_fade_out_time

	# 2. If there's time left, wait until the fade-out point
	if time_until_fade > 0:
		await get_tree().create_timer(time_until_fade).timeout

	# 3. Create the fade-out tween
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", -80.0, music_fade_out_time)

	# 4. Stop the player once the fade is complete to save resources
	tween.finished.connect(_on_music_track_done)

func _on_music_track_done() -> void:
	music_player.stop()
	current_music_track = (current_music_track + 1) % music_tracks.size()
	get_tree().create_timer(music_gap).connect("timeout", _on_gap_done)

func _on_gap_done() -> void:
	play_current_music_track()

func play_current_music_track() -> void:
	fade_in()
	fade_out_before_end()

func nav_to_title() -> void:
	hide_and_disable(world)
	hide_and_disable(win_screen)
	show_and_enable(title_screen)
	title_screen.start_animations()

func nav_to_win_screen() -> void:
	hide_and_disable(world)
	show_and_enable(win_screen)

func init_cursor_images() -> void:
	for key in filter_cursor_textures:
		var t := filter_cursor_textures[key]
		if t is Texture2D:
			_filter_cursor_images[key] = t.get_image()

func scale_cursor_images() -> void:
	if current_screen_scale != os_screen_scale:
		var scale_factor = current_screen_scale / os_screen_scale
		for img in _filter_cursor_images.values():
			if img is Image:
				var new_size: Vector2 = img.get_size() * scale_factor
				img.resize(new_size.x, new_size.y, Image.INTERPOLATE_BILINEAR)
		current_screen_scale = os_screen_scale

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().paused = true
		pause_menu.show()

var is_dragging_mouse := false
var drag_mouse_start_pos: Vector2i
var drag_stashed_mouse_mode: Input.MouseMode

var os_cursor_showing := false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if os_cursor_showing: return
		if is_dragging_mouse:
			# Get current desktop position (unaffected by Godot's coordinate system)
			var current_mouse_pos := DisplayServer.mouse_get_position()
			var delta := current_mouse_pos - drag_mouse_start_pos
			# Move window by desktop delta
			var current_window_pos := DisplayServer.window_get_position()
			DisplayServer.window_set_position(current_window_pos + delta)
			# Update anchor for next event
			drag_mouse_start_pos = current_mouse_pos
		else:
			# Non-dragging / typical mouse movement.
			if get_tree().paused: return
			world_blend_viewport.update_mouse_pos()
			software_mouse.position = event.position
	elif event.is_action_pressed("toggle_spotlight_filter"):
		match filter_color:
			FilterColor.NONE:
				pass
			FilterColor.RED:
				filter_color = FilterColor.BLUE
			FilterColor.BLUE:
				filter_color = FilterColor.RED
	elif event.is_action_pressed("snag_item"):
		if window_drag_block > 0: return
		if world.visible and not pause_menu.visible: return
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN: return
		is_dragging_mouse = true
		# Record global starting point - avoids "center-snap" issues
		drag_mouse_start_pos = DisplayServer.mouse_get_position()
		# Use HIDDEN instead of CAPTURED to maintain infinite movement without centering
		drag_stashed_mouse_mode = Input.mouse_mode
		Input.mouse_mode = Settings.drag_mouse_mode
	elif event.is_action_released("snag_item"):
		if not is_dragging_mouse: return
		is_dragging_mouse = false
		Input.mouse_mode = drag_stashed_mouse_mode
		_snap_window_to_screen()

const SNAP_MARGIN := 40.0

func _snap_window_to_screen() -> void:
	var window_pos := DisplayServer.window_get_position()
	var window_size := DisplayServer.window_get_size()
	var window_rect := Rect2i(window_pos, window_size)
	var is_visible_enough := false

	# Check all screens for 40x40px visibility
	for i in DisplayServer.get_screen_count():
		var screen_rect := DisplayServer.screen_get_usable_rect(i)
		var intersection := window_rect.intersection(screen_rect)
		if intersection.size.x >= SNAP_MARGIN and intersection.size.y >= SNAP_MARGIN:
			is_visible_enough = true
			break

	if not is_visible_enough:
		var screen := DisplayServer.window_get_current_screen()
		var usable := DisplayServer.screen_get_usable_rect(screen)

		var clamped_x: int = clamp(window_pos.x, 
			usable.position.x - (window_size.x - SNAP_MARGIN), 
			usable.end.x - SNAP_MARGIN)
		var clamped_y: int = clamp(window_pos.y, 
			usable.position.y - (window_size.y - SNAP_MARGIN), 
			usable.end.y - SNAP_MARGIN)
			
		DisplayServer.window_set_position(Vector2i(clamped_x, clamped_y))
		
		# Align software mouse with new local hardware position after snap
		software_mouse.position = get_viewport().get_mouse_position()

func set_window_layout(is_fullscreen: bool, resolution: Vector2i) -> void:
	if is_fullscreen:
		# 1. Clear borderless flag first to prevent OS state 'bleeding'
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		# 2. Use WINDOW_MODE_FULLSCREEN (non-exclusive) as requested
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		# 1. Force back to Windowed to allow resizing
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		# 2. Explicitly re-apply Borderless for your draggable window setup
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		# 3. Set Size
		DisplayServer.window_set_size(resolution)
		# 4. Center on the usable area of the current screen
		var screen = DisplayServer.window_get_current_screen()
		var screen_rect = DisplayServer.screen_get_usable_rect(screen)
		var window_size = DisplayServer.window_get_size()
		DisplayServer.window_set_position(screen_rect.position + (Vector2i(screen_rect.size) - window_size) / 2)

func get_window_center() -> Vector2:
	return get_viewport().get_visible_rect().size * 0.5

func _on_title_screen_dismissed() -> void:
	hide_and_disable(title_screen)
	show_and_enable(world)

func _on_pause_menu_went_to_title() -> void:
	nav_to_title()

func show_and_enable(n: Node) -> void:
	n.show()
	n.process_mode = PROCESS_MODE_INHERIT
	n.set_process_input(true)

func hide_and_disable(n: Node) -> void:
	n.hide()
	n.process_mode = PROCESS_MODE_DISABLED
	n.set_process_input(false)

func _on_win_screen_dismissed() -> void:
	nav_to_title()


func _on_pause_menu_boop_required() -> void:
	play_boop()


func _on_pause_menu_toggled_resolution_dropdown(toggled_on: bool) -> void:
	if toggled_on:
		is_dragging_mouse = false
		os_cursor_showing = true
		stashed_filter_color = filter_color
		filter_color = FilterColor.NONE
	else:
		software_mouse.position = get_viewport().get_mouse_position()
		filter_color = stashed_filter_color
		os_cursor_showing = false
		
		var target_res = pause_menu.get_selected_resolution()
		var is_fs = pause_menu.get_fullscreen_state()
		set_window_layout(is_fs, target_res)

var slider_is_dragging := false
func _on_pause_menu_slider_drag_started(_slider: Slider) -> void:
	slider_is_dragging = true


func _on_pause_menu_slider_drag_ended(_slider: Slider) -> void:
	slider_is_dragging = false

var window_drag_block := 0

func _on_window_drag_block_should_increment() -> void:
	window_drag_block += 1

func _on_window_drag_block_should_decrement() -> void:
	window_drag_block = max(0, window_drag_block - 1)
	
func _on_window_drag_block_should_clear() -> void:
	window_drag_block = 0
