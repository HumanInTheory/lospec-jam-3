@tool
class_name GridCursor
extends Sprite2D

signal accept_pressed(cell)
signal moved(new_cell)

@export var grid : Grid = preload("res://src/world_grid.tres")

var cell_location := Vector2i(-10, -10) :
	set(new_cell):
		if new_cell == cell_location:
			return
		
		cell_location = new_cell
		position = grid.cell_to_pixel_location(cell_location)

var disabled : bool = false

func _ready() -> void:
	position = grid.cell_to_pixel_location(cell_location)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("touch"):
		print("touch")
		on_touch(get_global_mouse_position())
		get_viewport().set_input_as_handled()


func on_touch(pixel: Vector2) -> void:
	var target_cell := grid.pixel_to_cell_location(pixel)
	
	if cell_location == target_cell:
		accept_pressed.emit(cell_location)
		cell_location = Vector2i(-10, -10)
		return
	
	cell_location = target_cell
	moved.emit(cell_location)
