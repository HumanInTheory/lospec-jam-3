extends AnimatedSprite2D


# Called on input
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("touch"):
		if not is_playing():
			play("swing")
