extends SubViewport

signal mouse_moved(pos: Vector2)

func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseMotion:
		# The mouse position within the 0 to size.x/y range of THIS viewport.
		# It is the "canonical" coordinate for FRAGCOORD.
		var local_mouse := get_mouse_position()
		# Update the position of the software mouse (main will handle this).
		mouse_moved.emit(local_mouse)
		# Update the mouse position Global Shader Parameter.
		RenderingServer.global_shader_parameter_set("mouse_pos", local_mouse)


func _on_blue_mask_pressed(source: BaseButton) -> void:
	disable_mask_button(source)

func _on_red_mask_pressed(source: BaseButton) -> void:
	disable_mask_button(source)

func disable_mask_button(source: BaseButton) -> void:
	source.set_deferred("disabled", true)
