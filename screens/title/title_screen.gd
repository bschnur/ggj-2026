extends CanvasLayer

# Commented out while testing color filter cursor.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("dismiss_title_screen"):
		leave_title()
		get_viewport().set_input_as_handled()

signal dismissed

func leave_title() -> void:
	dismissed.emit()
