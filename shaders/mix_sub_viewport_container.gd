extends SubViewportContainer

@export var below_texture: Texture2D
@export var above_texture: Texture2D

@onready var below_texture_rect: TextureRect = %BelowTextureRect
@onready var above_texture_rect: TextureRect = %AboveTextureRect

@onready var mask_buttons := find_children("*", "TextureButton")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	below_texture_rect.texture = below_texture
	above_texture_rect.texture = above_texture
	
func update_mouse_pos() -> void:
	%MixSubViewport.update_mouse_pos()

signal mask_found
func _on_mix_sub_viewport_mask_found() -> void:
	mask_found.emit()

func reset_masks() -> void:
	for b in mask_buttons:
		b.set_deferred("disabled", false)
