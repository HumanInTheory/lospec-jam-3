extends AudioStreamPlayer


func _on_title_manager_game_start_sfx() -> void:
	stream.set_initial_clip(0)
	play()
