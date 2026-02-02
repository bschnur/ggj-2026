extends SubViewport

func update_mouse_pos() -> void:
	# The mouse position within the 0 to size.x/y range of THIS viewport.
	# It is the "canonical" coordinate for FRAGCOORD.
	var local_mouse := get_mouse_position()
	# Update the mouse position Global Shader Parameter.
	RenderingServer.global_shader_parameter_set("mouse_pos", local_mouse)

signal mask_found

func _on_blue_mask_pressed(source: BaseButton) -> void:
	_on_mask_button_pressed(source)

func _on_red_mask_pressed(source: BaseButton) -> void:
	_on_mask_button_pressed(source)

func _on_mask_button_pressed(source: BaseButton) -> void:
	source.set_deferred("disabled", true)
	mask_found.emit()
