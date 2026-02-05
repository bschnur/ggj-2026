extends SubViewport

#func update_mouse_pos() -> void:
	## The mouse position within the 0 to size.x/y range of THIS viewport.
	## It is the "canonical" coordinate for FRAGCOORD.
	#var local_mouse := get_mouse_position()
	## Update the mouse position Global Shader Parameter.
	#RenderingServer.global_shader_parameter_set("mouse_pos", local_mouse)

signal mask_location_clicked(btn: BaseButton, col: Main.FilterColor)

func _on_blue_mask_pressed(btn: BaseButton) -> void:
	_on_mask_button_pressed(btn, Main.FilterColor.BLUE)

func _on_red_mask_pressed(btn: BaseButton) -> void:
	_on_mask_button_pressed(btn, Main.FilterColor.RED)

func _on_mask_button_pressed(btn: BaseButton, color: Main.FilterColor) -> void:
	mask_location_clicked.emit(btn, color)
