extends AudioStreamPlayer



func _on_splash_manager_splash_audio_trigger() -> void:
	stream.set_initial_clip(0)
	play()


func _on_battle_manager_battle_audio_trigger() -> void:
	stream.set_initial_clip(1)
	play()
