class_name GameBoard
extends CanvasLayer


enum phase {Player, Enemy}
enum action {None, Move, Attack}

const Directions = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]

@export var grid : Grid = preload("res://src/world_grid.tres")

var units := {}

var active_unit : Unit
var walkable_cells : Array[Vector2i]
var solid_cells : Array[Vector2i]

var current_phase : phase = phase.Player
var current_action : action = action.Move
var current_options : PackedStringArray = []

@onready var world_map : TileMapLayer = $"world-map"
@onready var unit_overlay : UnitOverlay = $"unit-overlay"
@onready var unit_path : UnitPath = $unit_path
@onready var ui : OverworldUi = $"overworld-ui"
@onready var menu : MenuUi = $menu

func _ready() -> void:
	_reinitialize()
	ui.hide_unit_info()
	ui.hide_terrain_info()
	for cell in world_map.get_used_cells():
		if world_map.get_cell_tile_data(cell).get_custom_data("Solid"):
			solid_cells.append(cell)


func _reinitialize() -> void:
	units.clear()
	
	for child in get_children():
		if child is not Unit:
			continue
		
		units[child.cell_location] = child as Unit


func is_occupied_cell(cell : Vector2i) -> bool:
	return units.has(cell) or cell in solid_cells


func flood_fill(start_cell : Vector2i, max_distance : int) -> Array[Vector2i]:
	var array : Array[Vector2i] = []
	
	var stack : Array[Vector2i] = [start_cell]
	var distance_stack : Array[int] = [0]
	
	while not stack.is_empty():
		var current_cell : Vector2i = stack.pop_back()
		var distance : int = distance_stack.pop_back()
		
		if not grid.cell_in_grid(current_cell):
			continue
		
		if current_cell in array:
			continue
		
		if distance > max_distance:
			continue
		
		array.append(current_cell)
		for direction in Directions:
			var coordinates: Vector2i = current_cell + direction
			
			if is_occupied_cell(coordinates):
				continue
			if coordinates in array:
				continue

			# This is where we extend the stack.
			stack.push_front(coordinates)
			distance_stack.push_front(distance + 1)
	
	return array


# Returns an array of cells a given unit can walk using the flood fill algorithm.
func get_walkable_cells(unit: Unit) -> Array[Vector2i]:
	return flood_fill(unit.cell_location, unit.speed)


func open_menu(location : Vector2):
	$grid_cursor.disabled = true
	menu.show_menu(location, current_options)


func return_from_menu():
	$grid_cursor.disabled = false


func select_cell(cell : Vector2i) -> void:
	ui.show_terrain_info(cell.x, cell.y)


func deselect_cell() -> void:
	ui.hide_terrain_info()


func select_unit(target_cell : Vector2i) -> void:
	if not units.has(target_cell):
		current_options.clear()
		current_options.append("End Turn")
		open_menu(grid.cell_to_pixel_location(target_cell))
		return
	
	if units[target_cell].has_acted:
		current_options.clear()
		current_options.append("End Turn")
		open_menu(grid.cell_to_pixel_location(target_cell))
		return
	
	if units[target_cell].army != current_phase:
		current_options.clear()
		current_options.append("Attack")
		open_menu(grid.cell_to_pixel_location(target_cell))
		return
	
	if active_unit:
		deselect_active_unit()
		clear_active_unit()
	
	active_unit = units[target_cell]
	active_unit.is_selected = true
	
	if not active_unit.has_walked:
		walkable_cells = get_walkable_cells(active_unit)
		unit_overlay.draw_cell_overlay(walkable_cells)
		unit_path.initialize(solid_cells)
		current_action = action.Move
	else:
		current_options.clear()
		current_options.append("Wait")
		open_menu(grid.cell_to_pixel_location(target_cell))
	ui.show_unit_info()


func deselect_active_unit() -> void:
	active_unit.is_selected = false
	unit_overlay.clear()
	unit_path.stop()
	ui.hide_unit_info()
	current_action = action.None


func clear_active_unit() -> void:
	active_unit = null
	walkable_cells.clear()


func move_active_unit(new_cell : Vector2i) -> void:
	if new_cell not in walkable_cells:
		return
	
	units.erase(active_unit.cell_location)
	units[new_cell] = active_unit
	deselect_active_unit()
	active_unit.walk_path(unit_path.current_path)
	await(active_unit.finished_walking)
	clear_active_unit()


func end_phase() -> void:
	for key in units:
		var unit = units[key]
		unit.has_acted = false
		unit.has_walked = false
	
	if active_unit:
		deselect_active_unit()
		clear_active_unit()
	
	match current_phase:
		phase.Player:
			current_phase = phase.Enemy
		phase.Enemy:
			current_phase = phase.Player


func _on_grid_cursor_moved(new_cell: Vector2i) -> void:
	print("cursor moved")
	if active_unit and active_unit.is_selected:
		if current_action == action.Move:
			select_cell(new_cell)
			if new_cell in walkable_cells:
				unit_path.draw_path(active_unit.cell_location, new_cell)
			else:
				unit_path.clear()
		else:
			deselect_active_unit()
			clear_active_unit()
	if not active_unit:
		select_unit(new_cell)


func _on_grid_cursor_accept_pressed(cell: Vector2i) -> void:
	print("accept pressed")
	deselect_cell()
	if active_unit and active_unit.is_selected:
		if active_unit.cell_location != cell and cell in walkable_cells:
			move_active_unit(cell)
		else:
			deselect_active_unit()
			clear_active_unit()


func _on_menu_clicked_item(item: int) -> void:
	print("on clicked menu")
	match current_options[item]:
		"Wait":
			print("waiting")
			active_unit.has_acted = true
		"End Turn":
			end_phase()
	return_from_menu()


func _on_menu_clicked_away() -> void:
	print("on clicked away")
	return_from_menu()
