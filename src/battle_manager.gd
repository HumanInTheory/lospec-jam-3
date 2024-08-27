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
var current_level : Node

@export var levels : Array[PackedScene]
@export var current_level_index : int = 0

func start_game() -> void:
	print_debug("Starting game")
	battle_audio_trigger.emit()
	load_map()

func end_game() -> void:
	print_debug("Ending game")
	
	unload_map()


func enter_state(new_state : Battle_State, old_state : Battle_State) -> void:
	print_debug("Entering " + Battle_State.keys()[new_state])
	
	match new_state:
		Battle_State.Load_Map:
			load_map()


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
