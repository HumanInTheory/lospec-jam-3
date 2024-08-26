# Manages the grid for overworld movement
class_name Grid
extends Resource

# Grid size in rows, columns
@export var size := Vector2i(20, 20)

# Cell size in pixels
@export var cell_size := Vector2i(16, 16)

func cell_to_pixel_location(cell_location: Vector2i) -> Vector2:
	return cell_location * cell_size + cell_size / 2

func pixel_to_cell_location(pixel_location: Vector2) -> Vector2i:
	return Vector2i(pixel_location) / cell_size

func cell_in_grid(cell_location: Vector2i) -> bool:
	return !(cell_location.x < 0 or cell_location.y < 0 or cell_location.x > 15 or cell_location.y > 8)

func clamp_cell_location(cell_location: Vector2i) -> Vector2i:
	var out := cell_location
	out.x = clampi(out.x, 0, size.x)
	out.y = clampi(out.y, 0, size.y)
	return out

func cell_to_index(cell_location: Vector2i) -> int:
	return cell_location.y * size.x + cell_location.y
