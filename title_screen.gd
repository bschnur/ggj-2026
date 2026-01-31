extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%"Mix Viewport".size = get_viewport().get_visible_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
