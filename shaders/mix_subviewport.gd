extends SubViewport

signal mask_location_clicked(btn: BaseButton, col: Main.FilterColor)

func _on_blue_mask_pressed(btn: BaseButton) -> void:
	_on_mask_button_pressed(btn, Main.FilterColor.BLUE)

func _on_red_mask_pressed(btn: BaseButton) -> void:
	_on_mask_button_pressed(btn, Main.FilterColor.RED)

func _on_mask_button_pressed(btn: BaseButton, color: Main.FilterColor) -> void:
	mask_location_clicked.emit(btn, color)
