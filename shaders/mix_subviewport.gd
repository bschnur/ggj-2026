extends SubViewport

func _process(_delta: float) -> void:
	# The mouse position within the 0 to size.x/y range of THIS viewport.
	# It is the "canonical" coordinate for FRAGCOORD.
	var local_mouse = get_mouse_position()
	# Update the mouse position Global Shader Parameter.
	RenderingServer.global_shader_parameter_set("mouse_pos", local_mouse)
