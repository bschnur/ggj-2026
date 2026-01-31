extends CanvasLayer

#func _ready() -> void:
	#pass

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseMotion and not event is InputEventJoypadMotion:
		leave_title()
	get_viewport().set_input_as_handled()

signal dismissed

func leave_title() -> void:
	dismissed.emit()
