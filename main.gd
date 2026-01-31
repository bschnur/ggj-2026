extends Node

@onready var title_screen := %TitleScreen
@onready var pause_menu := %PauseMenu

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().paused = true
		pause_menu.show()
		

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
