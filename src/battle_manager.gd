extends Node2D

signal victory
signal loss
signal battle_audio_trigger

enum Battle_State {
	None,
	Load_Map,
	Idle_Player_Phase,
	Enemy_Phase,
	Victory,
	Loss,
}

var current_state : Battle_State = Battle_State.None
var current_level : Level
var enemy_units : Array[Unit]

var sprites := {}

@export var grid : Grid
@export var levels : Array[PackedScene]
@export var current_level_index : int = 0
@export var player_units : Array[Unit]

func start_game() -> void:
	print_debug("Starting game")
	battle_audio_trigger.emit()
	switch_state(Battle_State.Load_Map)

func end_game() -> void:
	print_debug("Ending game")
	
	unload_map()


func enter_state(new_state : Battle_State, old_state : Battle_State) -> void:
	print_debug("Entering " + Battle_State.keys()[new_state])
	
	match new_state:
		Battle_State.Load_Map:
			load_map()
			load_characters()
			sync_animations()


func exit_state(old_state : Battle_State, new_state : Battle_State) -> void:
	print_debug("Exiting " + Battle_State.keys()[old_state])
	
	match old_state:
		Battle_State.Victory:
			unload_map()
			current_level_index += 1


func switch_state(new_state : Battle_State) -> void:
	exit_state(current_state, new_state)
	enter_state(new_state, current_state)
	current_state = new_state


func load_map() -> void:
	print_debug("Loading map " + str(current_level_index))
	current_level = levels[current_level_index].instantiate()
	add_child(current_level)


func unload_map() -> void:
	print_debug("Unloading map " + str(current_level_index))
	remove_child(current_level)
	current_level.free()


func spawn_unit(unit : Unit, grid_location : Vector2i) -> void:
	print_debug("spawning unit " + unit.name + " at " + str(grid_location))
	var new_sprite := AnimatedSprite2D.new()
	new_sprite.sprite_frames = unit.appearance
	new_sprite.offset.y = -4
	new_sprite.position = grid.cell_to_pixel_location(grid_location)
	sprites[unit] = new_sprite
	current_level.add_child(new_sprite)


func load_characters() -> void:
	for i in range(len(player_units)):
		spawn_unit(player_units[i], grid.pixel_to_cell_location(current_level.player_spawns[i].position))
	for i in range(len(current_level.enemies)):
		spawn_unit(current_level.enemies[i], grid.pixel_to_cell_location(current_level.enemy_spawns[i].position))


func sync_animations() -> void:
	for key in sprites:
		var s : AnimatedSprite2D = sprites[key]
		s.play("idle")
