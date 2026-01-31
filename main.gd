extends Node

@onready var title_screen := %TitleScreen
@onready var pause_menu := %PauseMenu

enum FilterColor {
	NONE = 0,
	RED = 1,
	BLUE = 2,
}

@export var filter_cursor_textures: Dictionary[FilterColor, Texture2D]

var filter_color := FilterColor.NONE:
	set(value):
		filter_color = value
		var cursor_texture := filter_cursor_textures[filter_color]
		var hotspot := Vector2.ZERO
		if cursor_texture is Texture2D:
			hotspot = cursor_texture.get_size() * 0.5
		Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, hotspot)
		RenderingServer.global_shader_parameter_set("mouse_filtering_color_id", filter_color)


func _ready() -> void:
	filter_color = FilterColor.RED

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().paused = true
		pause_menu.show()
	elif event.is_action_pressed("toggle_spotlight_filter"):
		match filter_color:
			#FilterColor.NONE:
				#pass
			FilterColor.RED:
				filter_color = FilterColor.BLUE
			FilterColor.BLUE:
				filter_color = FilterColor.RED
		

func _on_title_screen_dismissed() -> void:
	hide_title_screen()

func hide_title_screen() -> void:
	title_screen.hide()
	title_screen.process_mode = PROCESS_MODE_DISABLED

func show_title_screen() -> void:
	title_screen.show()
	title_screen.process_mode = PROCESS_MODE_INHERIT


func _on_pause_menu_went_to_title() -> void:
	# Todo: reset world
	show_title_screen()
