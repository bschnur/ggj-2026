extends CanvasLayer

signal dismissed

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseMotion and not event is InputEventJoypadMotion:
		dismissed.emit()
	get_viewport().set_input_as_handled()
