extends Node

var current_screen_scale := 1.0
# Todo: also store a scalar representing the current game scale compared to 1080p.
# This should be used to resize the mouse cursor images - and change the filter radius!
var os_screen_scale: float

@onready var title_screen := %TitleScreen
@onready var pause_menu := %PauseMenu
@onready var world := %World

var masks_remaining := 6

func _on_mask_found() -> void:
	masks_remaining -= 1
	if masks_remaining == 0:
		# YOU WIN!
		pass

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
		
		RenderingServer.global_shader_parameter_set("mouse_filtering_color_id", filter_color)

func set_software_mouse_cursor(cursor_texture: Texture2D, hotspot: Vector2, show := true) -> void:
	#var shape := Input.CURSOR_ARROW
	var s_mouse := %SoftwareMouse
	s_mouse.texture = cursor_texture
	s_mouse.offset = -hotspot
	if show:
		s_mouse.show()

func _ready() -> void:
	os_screen_scale = DisplayServer.screen_get_max_scale()
	init_cursor_images()
	scale_cursor_images()
	filter_color = FilterColor.RED
	nav_to_title()

func nav_to_title() -> void:
	hide_and_disable(world)
	show_and_enable(title_screen)
	title_screen.start_animations()

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
	elif event.is_action_pressed("toggle_spotlight_filter"):
		match filter_color:
			FilterColor.NONE:
				pass
			FilterColor.RED:
				filter_color = FilterColor.BLUE
			FilterColor.BLUE:
				filter_color = FilterColor.RED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		%SubViewportContainer2.update_mouse_pos()
		# The mouse position within the 0 to size.x/y range of THIS viewport.
		# It is the "canonical" coordinate for FRAGCOORD.
		var mouse_pos := (event as InputEventMouseMotion).position
		# Update the position of the software mouse.
		%SoftwareMouse.position = mouse_pos

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
