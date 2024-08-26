## Draw a cursor following the touch input.
## The TCH engine (probably) doesn't have the same built-in hardware cursor as a PC, so we can
## emulate something similar to drawing tablets with this class.
## Note that the cursor MAY lag behind the actual hardware cursor by a few frames. This is related
## to the relation between FPS (should be 60 with Vsync enabled), process times, and input cycles.
extends Sprite2D


func _ready() -> void:
	hide()
	set_process(false)


func _process(_delta: float) -> void:
	position = get_global_mouse_position()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("touch"):
		show()
		set_process(true)
	
	elif event.is_action_released("touch"):
		hide()
		set_process(false)
