extends CanvasLayer

@onready var current_submenu := %MainMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		if current_submenu == %MainMenu:
			unpause()
		elif current_submenu in [%OptionsMenu, %QuitMenu]:
			navigate(%MainMenu)

func navigate(submenu: Node) -> void:
	current_submenu.hide()
	current_submenu = submenu
	submenu.show()

func unpause() -> void:
	hide()
	#%MainMenu.show() # Redundant with current flow
	#%OptionsMenu.hide() # Redundant with current flow
	#%QuitMenu.hide() # Redundant with current flow
	get_tree().paused = false

func _on_resume_button_pressed() -> void:
	unpause()

func _on_options_button_pressed() -> void:
	navigate(%OptionsMenu)

func _on_quit_button_pressed() -> void:
	navigate(%QuitMenu)

func _on_options_cancel_pressed() -> void:
	# Todo: prompt user whether to discard changes, if there are any
	navigate(%MainMenu)

func _on_options_confirm_pressed() -> void:
	# Todo: apply any changes; display some sort of confirmation
	navigate(%MainMenu)

func _on_quit_to_title_button_pressed() -> void:
	pass # Todo: go to title

func _on_quit_to_desktop_button_pressed() -> void:
	get_tree().quit()

func _on_quit_back_button_pressed() -> void:
	navigate(%MainMenu)
