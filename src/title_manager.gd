extends TextureRect

signal enter_game
signal game_start_sfx

func start_title() -> void:
	show()
	mouse_filter = MouseFilter.MOUSE_FILTER_STOP
	# trigger title music?

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("touch"):
		enter_game.emit()

func end_title() -> void:
	hide()
	mouse_filter = MouseFilter.MOUSE_FILTER_PASS
	game_start_sfx.emit()
