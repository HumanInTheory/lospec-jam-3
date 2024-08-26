class_name UnitOverlay
extends TileMapLayer

func draw_cell_overlay(cells: Array[Vector2i]) -> void:
	#clear()
	
	for cell in cells:
		set_cell(cell, 0, Vector2i(1, 0), 0)
