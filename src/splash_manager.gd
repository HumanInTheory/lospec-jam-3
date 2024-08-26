extends AnimatedSprite2D

signal splash_audio_trigger
signal splash_complete

func start_splash() -> void:
	show()
	play("splash")
	splash_audio_trigger.emit()

func _on_animation_finished() -> void:
	splash_complete.emit()

func end_splash() -> void:
	hide()
