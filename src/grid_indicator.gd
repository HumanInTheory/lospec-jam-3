extends Sprite2D

@export var grid : Grid

func _on_battle_manager_selected_tile(tile: Vector2i) -> void:
	position = grid.cell_to_pixel_location(tile)
	show()


func _on_battle_manager_deselected_tile() -> void:
	hide()
