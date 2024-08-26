class_name UnitPath
extends TileMapLayer

@export var grid : Grid = preload("res://src/world_grid.tres")

var pathfinder : PathFinder
var current_path : Array[Vector2i]

func initialize(solid_cells : Array[Vector2i]) -> void:
	pathfinder = PathFinder.new(grid, solid_cells)


func draw_path(cell_start : Vector2i, cell_end : Vector2i) -> void:
	clear()
	current_path = pathfinder.get_cell_path(cell_start, cell_end)
	set_cells_terrain_path(current_path, 0, 0)


func stop() -> void:
	pathfinder = null
	clear()
