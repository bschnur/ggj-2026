extends SubViewportContainer

@export var below_texture: Texture2D
@export var above_texture: Texture2D

@onready var below_texture_rect: TextureRect = %BelowTextureRect
@onready var above_texture_rect: TextureRect = %AboveTextureRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	below_texture_rect.texture = below_texture
	above_texture_rect.texture = above_texture


signal mouse_moved(pos: Vector2)
func _on_mix_sub_viewport_mouse_moved(pos: Vector2) -> void:
	mouse_moved.emit(pos)
