extends SubViewportContainer

@export var below_texture: Texture2D
@export var above_texture: Texture2D

@onready var below_texture_rect: TextureRect = %BelowTextureRect
@onready var above_texture_rect: TextureRect = %AboveTextureRect

@onready var mask_buttons := find_children("*", "TextureButton")

@onready var mix_sub_viewport: SubViewport = %MixSubViewport

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	below_texture_rect.texture = below_texture
	above_texture_rect.texture = above_texture
	
#func update_mouse_pos() -> void:
	#%MixSubViewport.update_mouse_pos()

func update_mouse_pos() -> void:
	var local_mouse := get_local_mouse_position()
	var svp_size := mix_sub_viewport.size
	var scale_vec := Vector2(
		svp_size.x / size.x,
		svp_size.y / size.y)
	RenderingServer.global_shader_parameter_set("mouse_pos", local_mouse * scale_vec)

signal mask_location_clicked(btn: BaseButton, col: Main.FilterColor)

func _on_mix_sub_viewport_mask_location_clicked(btn: BaseButton, col: Main.FilterColor) -> void:
	mask_location_clicked.emit(btn, col)

func reset_masks() -> void:
	for b in mask_buttons:
		b.set_deferred("disabled", false)


func _on_mix_sub_viewport_mask_found() -> void:
	pass # Replace with function body.
