extends Node
class_name Main

# TODO:
# Handle display settings better:
# 1. X Center window on screen when changing to windowed mode.
# 2. Make window draggable when not in fullscreen.
# 3. Make fullscreen and resolution settings apply correctly regardless of the
# 		combination in which they are selected and applied.
# 4a. Make sure the fullscreen setting is respected on subsequent launch.
# 4b. When loading fresh, don't draw the weird crazy background outside the viewport
#		(check we set mode on load based on settings).
# 5. Address the issue of low resolution keyhole syndrome
# 		(maybe involves minimum sizes, anchors, or stretch?).

var current_screen_scale := 1.0
# Todo: also store a scalar representing the current game scale compared to 1080p.
# This should be used to resize the mouse cursor images - and change the filter radius!
var os_screen_scale: float

@onready var title_screen := %TitleScreen
@onready var pause_menu := %PauseMenu
@onready var world := %World
@onready var win_screen := %WinScreen

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
		%SubViewportContainer2.reset_masks()
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
		filter_color = value
		
		if filter_color != FilterColor.NONE:
			var cursor_texture := filter_cursor_textures[filter_color]
			var hotspot := Vector2.ZERO
			
			hotspot = cursor_texture.get_size() * 0.5
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
			set_software_mouse_cursor(cursor_texture, hotspot, true)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			#Input.set_custom_mouse_cursor(cursor_img, Input.CURSOR_ARROW, hotspot)
		
		RenderingServer.global_shader_parameter_set("mouse_lens_color_id", filter_color)

func set_software_mouse_cursor(cursor_texture: Texture2D, hotspot: Vector2, show := true) -> void:
	#var shape := Input.CURSOR_ARROW
	var s_mouse := %SoftwareMouse
	s_mouse.texture = cursor_texture
	s_mouse.offset = -hotspot
	if show:
		s_mouse.show()

#var initialization_finished := false

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
	#initialization_finished = true

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
	#if initialization_finished:
	if event.is_action_pressed("pause"):
		get_tree().paused = true
		pause_menu.show()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		%SubViewportContainer2.update_mouse_pos()
		# The mouse position within the 0 to size.x/y range of THIS viewport.
		# It is the "canonical" coordinate for FRAGCOORD.
		var mouse_pos := (event as InputEventMouseMotion).position
		# Update the position of the software mouse.
		%SoftwareMouse.position = mouse_pos
	elif event.is_action_pressed("toggle_spotlight_filter"):
		match filter_color:
			FilterColor.NONE:
				pass
			FilterColor.RED:
				filter_color = FilterColor.BLUE
			FilterColor.BLUE:
				filter_color = FilterColor.RED

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


func _on_mouse_moved(pos: Vector2) -> void:
	%SoftwareMouse.position = pos


func _on_win_screen_dismissed() -> void:
	nav_to_title()


func _on_pause_menu_boop_required() -> void:
	play_boop()
