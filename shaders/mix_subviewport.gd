extends SubViewport

func update_mouse_pos() -> void:
	# The mouse position within the 0 to size.x/y range of THIS viewport.
	# It is the "canonical" coordinate for FRAGCOORD.
	var local_mouse := get_mouse_position()
	# Update the mouse position Global Shader Parameter.
	RenderingServer.global_shader_parameter_set("mouse_pos", local_mouse)


func _on_blue_mask_pressed(source: BaseButton) -> void:
	disable_mask_button(source)

func _on_red_mask_pressed(source: BaseButton) -> void:
	disable_mask_button(source)

func disable_mask_button(source: BaseButton) -> void:
	source.set_deferred("disabled", true)
