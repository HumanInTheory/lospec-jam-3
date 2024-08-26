extends AnimatedSprite2D


func on_move_character(target: Vector2i) -> void:
	print("moved to", target)
	position = Vector2(target * 16)
