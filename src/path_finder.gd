class_name PathFinder
extends Resource

const Directions = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]

var grid : Grid
var astar := AStarGrid2D.new()

func _init(_grid : Grid, solid_cells : Array[Vector2i]) -> void:
	grid = _grid
	
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	
	astar.region = Rect2i(Vector2i(0, 0), grid.size)
	astar.update()
	for solid_cell in solid_cells:
		astar.set_point_solid(solid_cell)


func get_cell_path(start : Vector2i, end : Vector2i) -> Array[Vector2i]:
	if not grid.cell_in_grid(start) or not grid.cell_in_grid(end):
		return []
	
	return astar.get_id_path(start, end)
