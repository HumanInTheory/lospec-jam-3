extends Node2D

signal victory
signal loss
signal battle_audio_trigger
signal selected_tile(tile: Vector2i)
signal deselected_tile()
signal selected_unit(unit: Unit)
signal deselected_unit
signal initiate_attack(actor: Unit, victim: Unit, backdrop: int)

enum Battle_State {
	None,
	Load_Map,
	Player_Phase,
	Idle_Player_Phase,
	Tile_Select,
	Player_Tile_Orders,
	Unit_Select,
	Player_Unit_Move,
	Player_Confirm_Move,
	Player_Unit_Moving,
	Player_Unit_Orders,
	Player_Unit_Attack,
	Player_Confirm_Attack,
	Player_Unit_Attacking,
	Enemy_Phase,
	Enemy_Unit_Move,
	Enemy_Unit_Attack,
	Victory,
	Loss,
}

const Directions = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]

var current_state : Battle_State = Battle_State.None
var current_level : Level
var enemy_units : Array[Unit]

var units_by_tile := {}
var active_pixel : Vector2
var active_tile : Vector2i
var active_unit : Unit

var pathfinder := AStarGrid2D.new()
var dijkstra_map : Array[int] = []

@export var grid : Grid
@export var levels : Array[PackedScene]
@export var current_level_index : int = 0
@export var player_units : Array[Unit]

@onready var grid_overlay := $grid_overlay
@onready var menu := $menu
@onready var phase_wipe := $phase_wipe

func start_game() -> void:
	print_debug("Starting game")
	switch_state(Battle_State.Load_Map)

func end_game() -> void:
	print_debug("Ending game")
	
	unload_map()


func enter_state(new_state : Battle_State, old_state : Battle_State) -> void:
	print_debug("Entering " + Battle_State.keys()[new_state])
	
	match new_state:
		Battle_State.Load_Map:
			load_map()
			load_pathfinder()
			load_characters()
			sync_animations()
			switch_state(Battle_State.Player_Phase)
		Battle_State.Player_Phase:
			for unit in enemy_units:
				unit.refresh()
				sync_animations()
			phase_wipe.show()
			phase_wipe.play("player")
			await(phase_wipe.animation_finished)
			phase_wipe.hide()
			switch_state(Battle_State.Idle_Player_Phase)
		Battle_State.Idle_Player_Phase:
			pass
		Battle_State.Tile_Select:
			selected_tile.emit(active_tile)
			active_unit = units_by_tile.get(active_tile)
			if active_unit:
				switch_state(Battle_State.Unit_Select)
		Battle_State.Player_Tile_Orders:
			menu.show_menu(grid.cell_to_pixel_location(active_tile), [menu.Menu_Options.End_Turn])
		Battle_State.Unit_Select:
			selected_unit.emit(active_unit)
			if active_unit.can_move() && player_units.has(active_unit):
				switch_state(Battle_State.Player_Unit_Move)
		Battle_State.Player_Unit_Move:
			set_path_weights_by_unit(active_unit)
			grid_overlay.show()
		Battle_State.Player_Confirm_Move:
			selected_tile.emit(active_tile)
		Battle_State.Player_Unit_Moving:
			units_by_tile.erase(grid.pixel_to_cell_location(active_unit.game_piece.position))
			active_unit.move_unit(active_tile)
			units_by_tile[active_tile] = active_unit
			switch_state(Battle_State.Unit_Select)
		Battle_State.Player_Unit_Orders:
			menu.show_menu(grid.cell_to_pixel_location(active_tile), [menu.Menu_Options.Attack, menu.Menu_Options.Wait])
		Battle_State.Player_Unit_Attack:
			set_attack_overlay_by_unit(active_unit)
		Battle_State.Player_Confirm_Attack:
			selected_tile.emit(active_tile)
			selected_unit.emit(units_by_tile[active_tile])
		Battle_State.Player_Unit_Attacking:
			initiate_attack.emit(active_unit, units_by_tile[active_tile],
				current_level.get_cell_tile_data(active_tile).get_custom_data("type"))
		Battle_State.Enemy_Phase:
			for unit in player_units:
				unit.refresh()
				sync_animations()
			phase_wipe.show()
			phase_wipe.play("enemy")
			await(phase_wipe.animation_finished)
			phase_wipe.hide()
			switch_state(Battle_State.Player_Phase)


func exit_state(old_state : Battle_State, new_state : Battle_State) -> void:
	print_debug("Exiting " + Battle_State.keys()[old_state])
	
	match old_state:
		Battle_State.None:
			battle_audio_trigger.emit()
			init_pathfinder()
		Battle_State.Player_Tile_Orders:
			menu.hide_menu()
			if new_state == Battle_State.Idle_Player_Phase or new_state == Battle_State.Tile_Select:
				deselected_unit.emit()
				deselected_tile.emit()
		Battle_State.Unit_Select:
			if new_state == Battle_State.Idle_Player_Phase or new_state == Battle_State.Tile_Select:
				deselected_unit.emit()
				deselected_tile.emit()
		Battle_State.Player_Unit_Move, Battle_State.Player_Confirm_Move:
			if new_state != Battle_State.Player_Confirm_Move:
				for cell in grid_overlay.get_used_cells():
					dijkstra_map[cell.y * grid.size.x + cell.x] = 1000000
				grid_overlay.clear()
			if new_state == Battle_State.Idle_Player_Phase or new_state == Battle_State.Tile_Select:
				deselected_unit.emit()
				deselected_tile.emit()
		Battle_State.Player_Unit_Orders:
			menu.hide_menu()
			if new_state == Battle_State.Idle_Player_Phase or new_state == Battle_State.Tile_Select:
				deselected_unit.emit()
				deselected_tile.emit()
		Battle_State.Player_Unit_Attack, Battle_State.Player_Confirm_Attack:
			if new_state != Battle_State.Player_Confirm_Attack:
				grid_overlay.clear()
			if new_state == Battle_State.Idle_Player_Phase or new_state == Battle_State.Tile_Select:
				deselected_unit.emit()
				deselected_tile.emit()
		Battle_State.Player_Unit_Attacking:
			active_unit.commit_act()
			deselected_unit.emit()
			deselected_tile.emit()
		Battle_State.Victory:
			unload_map()
			current_level_index += 1


func switch_state(new_state : Battle_State) -> void:
	exit_state(current_state, new_state)
	var old_state = current_state
	current_state = new_state
	enter_state(new_state, old_state)


func init_pathfinder() -> void:
	pathfinder.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER


func load_map() -> void:
	print_debug("Loading map " + str(current_level_index))
	current_level = levels[current_level_index].instantiate()
	grid.size = current_level.get_used_rect().size
	enemy_units = current_level.enemies
	add_child(current_level)


func unload_map() -> void:
	print_debug("Unloading map " + str(current_level_index))
	remove_child(current_level)
	current_level.free()


func load_pathfinder() -> void:
	print_debug("Loading pathfinder for current map")
	pathfinder.clear()
	pathfinder.region = Rect2i(Vector2i(0, 0), grid.size)
	pathfinder.update()
	dijkstra_map.clear()
	dijkstra_map.resize(grid.size.x * grid.size.y)
	for cell in current_level.get_used_cells():
		dijkstra_map[cell.y * grid.size.x + cell.x] = 1000000
		if current_level.get_cell_tile_data(cell).get_custom_data("type") == 0:
			pathfinder.set_point_solid(cell)


func spawn_unit(unit : Unit, grid_location : Vector2i) -> void:
	print_debug("spawning unit " + unit.name + " at " + str(grid_location))
	var new_sprite := AnimatedSprite2D.new()
	new_sprite.sprite_frames = unit.appearance
	new_sprite.play("idle")
	new_sprite.offset.y = -4
	new_sprite.position = grid.cell_to_pixel_location(grid_location)
	new_sprite.z_index = 2
	unit.game_piece = new_sprite
	units_by_tile[grid_location] = unit
	add_child(new_sprite)


func load_characters() -> void:
	print_debug("loading characters...")
	for i in range(len(player_units)):
		spawn_unit(player_units[i], grid.pixel_to_cell_location(current_level.player_spawns[i].position))
		player_units[i].set_grid(grid)
		player_units[i].refresh()
	for i in range(len(enemy_units)):
		spawn_unit(enemy_units[i], grid.pixel_to_cell_location(current_level.enemy_spawns[i].position))
		enemy_units[i].set_grid(grid)
		enemy_units[i].refresh()


func sync_animations() -> void:
	for key in units_by_tile:
		var s : AnimatedSprite2D = units_by_tile[key].game_piece
		s.frame = 0


func get_path_weight_by_unit(unit: Unit, type: int) -> int:
	match type:
		Level.Cell_Type.Grass:
			return 10
		Level.Cell_Type.Trees:
			return 20
		Level.Cell_Type.Road:
			return 7
	
	return 1000000


func set_path_weights_by_unit(unit: Unit) -> void:
	print_debug("Setting path weights")
	var start_cell := grid.pixel_to_cell_location(unit.game_piece.position)
	dijkstra_map[start_cell.y * grid.size.x + start_cell.x] = 0
	
	var stack : Array[Vector2i] = [start_cell]
	var distance_stack : Array[int] = [0]
	
	while not stack.is_empty():
		var current_cell : Vector2i = stack.pop_front()
		var distance : int = distance_stack.pop_front()
		
		if distance > dijkstra_map[current_cell.y * grid.size.x + current_cell.x]:
			continue
		
		if distance > unit.stats.movement * 10:
			continue
		
		dijkstra_map[current_cell.y * grid.size.x + current_cell.x] = distance
		grid_overlay.set_cell(current_cell, 0, Vector2i(1, 0))
		
		for direction in Directions:
			var coordinates: Vector2i = current_cell + direction
			
			if not grid.cell_in_grid(coordinates):
				continue
			
			if units_by_tile.has(coordinates):
				continue

			var new_distance : int = distance + get_path_weight_by_unit(unit, current_level.
					get_cell_tile_data(coordinates).
					get_custom_data("type"))
			var new_index : int = distance_stack.bsearch(new_distance)
			
			assert(stack.insert(new_index, coordinates) == OK)
			assert(distance_stack.insert(new_index, new_distance) == OK)


func set_attack_overlay_by_unit(unit: Unit) -> void:
	for x in range(active_tile.x - unit.weapon.range, active_tile.x + unit.weapon.range + 1):
		for y in range(active_tile.y - unit.weapon.range, active_tile.y + unit.weapon.range + 1):
			grid_overlay.set_cell(Vector2i(x, y), 0, Vector2i(2, 0))

func take_unit_action(action: int) -> void:
	match action:
		menu.Menu_Options.Attack:
			switch_state(Battle_State.Player_Unit_Attack)
		menu.Menu_Options.Wait:
			active_unit.commit_act()
			switch_state(Battle_State.Idle_Player_Phase)


func take_tile_action(action: int) -> void:
	match action:
		menu.Menu_Options.End_Turn:
			switch_state(Battle_State.Enemy_Phase)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action("touch"):
		return
	
	if event.is_pressed():
		handle_press(get_global_mouse_position())


func handle_press(location : Vector2) -> void:
	print_debug("Handling press")
	var grid_location := grid.pixel_to_cell_location(location)
	
	match current_state:
		Battle_State.Idle_Player_Phase:
			active_pixel = location
			active_tile = grid_location
			switch_state(Battle_State.Tile_Select)
		Battle_State.Tile_Select:
			if grid_location == active_tile:
				active_pixel = location
				switch_state(Battle_State.Player_Tile_Orders)
			else:
				active_pixel = location
				active_tile = grid_location
				switch_state(Battle_State.Tile_Select)
		Battle_State.Player_Tile_Orders:
			switch_state(Battle_State.Idle_Player_Phase)
		Battle_State.Unit_Select:
			if grid_location == active_tile:
				if units_by_tile[active_tile].can_act():
					active_pixel = location
					switch_state(Battle_State.Player_Unit_Orders)
				else:
					switch_state(Battle_State.Player_Tile_Orders)
			else:
				active_pixel = location
				active_tile = grid_location
				switch_state(Battle_State.Tile_Select)
		Battle_State.Player_Unit_Move:
			if grid_location == active_tile:
				active_pixel = location
				switch_state(Battle_State.Player_Unit_Orders)
			elif grid_overlay.get_cell_source_id(grid_location) != -1:
				active_pixel = location
				active_tile = grid_location
				switch_state(Battle_State.Player_Confirm_Move)
			else:
				active_pixel = location
				active_tile = grid_location
				switch_state(Battle_State.Tile_Select)
		Battle_State.Player_Confirm_Move:
			if grid_location == active_tile:
				switch_state(Battle_State.Player_Unit_Moving)
			elif grid_overlay.get_cell_source_id(grid_location) != -1:
				active_pixel = location
				active_tile = grid_location
				switch_state(Battle_State.Player_Confirm_Move)
			else:
				active_pixel = location
				active_tile = grid_location
				switch_state(Battle_State.Tile_Select)
		Battle_State.Player_Unit_Orders:
			switch_state(Battle_State.Idle_Player_Phase)
		Battle_State.Player_Unit_Attack:
			if grid_location == active_tile:
				active_pixel = location
				switch_state(Battle_State.Idle_Player_Phase)
			elif not units_by_tile.has(grid_location):
				active_pixel = location
				active_tile = grid_location
				switch_state(Battle_State.Tile_Select)
			else:
				active_pixel = location
				active_tile = grid_location
				switch_state(Battle_State.Player_Confirm_Attack)
		Battle_State.Player_Confirm_Attack:
			if grid_location == active_tile:
				switch_state(Battle_State.Player_Unit_Attacking)
			elif units_by_tile.has(grid_location):
				active_pixel = location
				active_tile = grid_location
				switch_state(Battle_State.Player_Confirm_Attack)
			else:
				active_pixel = location
				active_tile = grid_location
				switch_state(Battle_State.Tile_Select)


func _on_menu_clicked_item(item: Variant) -> void:
	match current_state:
		Battle_State.Player_Unit_Orders:
			take_unit_action(item)
		Battle_State.Player_Tile_Orders:
			take_tile_action(item)


func _on_menu_clicked_away() -> void:
	switch_state(Battle_State.Idle_Player_Phase)


func _on_attack_manager_attack_complete() -> void:
	if current_state == Battle_State.Player_Unit_Attacking:
		switch_state(Battle_State.Idle_Player_Phase)
	else:
		print_debug("Battle State error")


func _on_attack_manager_actor_died() -> void:
	match current_state:
		Battle_State.Player_Unit_Attacking:
			units_by_tile.erase(grid.pixel_to_cell_location(active_unit.game_piece.position))
			active_unit.game_piece.queue_free()
			player_units.remove_at(player_units.find(active_unit))
			active_unit.free()
			switch_state(Battle_State.Idle_Player_Phase)


func _on_attack_manager_victim_died() -> void:
	match current_state:
		Battle_State.Player_Unit_Attacking:
			var unit_to_kill : Unit = units_by_tile[active_tile]
			units_by_tile.erase(active_tile)
			unit_to_kill.game_piece.queue_free()
			enemy_units.remove_at(enemy_units.find(unit_to_kill))
			switch_state(Battle_State.Idle_Player_Phase)
