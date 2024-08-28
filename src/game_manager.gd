extends Node

enum Game_State {
	None,
	Splash_Screen,
	Title_Screen,
	Battle,
	Victory,
	Loss,
}

@export var skip_splash : bool = false
@export var skip_title : bool = false

var game_state : Game_State = Game_State.None
@onready var splash_manager = $splash_manager
@onready var title_manager = $title_manager
@onready var battle_manager = $battle_manager
@onready var result_manager = $result_manager

func _ready() -> void:
	if not skip_splash:
		switch_state(Game_State.Splash_Screen)
		return
	
	if not skip_title:
		switch_state(Game_State.Title_Screen)
		return
	
	switch_state(Game_State.Battle)


func enter_state(new_state : Game_State, old_state : Game_State) -> void:
	print_debug("Entering " + Game_State.keys()[new_state])
	
	match new_state:
		Game_State.Splash_Screen:
			splash_manager.start_splash()
		Game_State.Title_Screen:
			title_manager.start_title()
		Game_State.Battle:
			battle_manager.start_game()


func exit_state(old_state : Game_State, new_state : Game_State) -> void:
	print_debug("Exiting " + Game_State.keys()[old_state])
	
	match old_state:
		Game_State.Splash_Screen:
			splash_manager.end_splash()
		Game_State.Title_Screen:
			title_manager.end_title()
		Game_State.Battle:
			battle_manager.end_game()


func switch_state(new_state : Game_State) -> void:
	exit_state(game_state, new_state)
	enter_state(new_state, game_state)
	game_state = new_state


func _on_splash_manager_splash_complete() -> void:
	if game_state == Game_State.Splash_Screen:
		switch_state(Game_State.Title_Screen)
	else:
		print_debug("State Error")


func _on_title_manager_enter_game() -> void:
	if game_state == Game_State.Title_Screen:
		switch_state(Game_State.Battle)
	else:
		print_debug("State Error")


func _on_battle_manager_victory() -> void:
	if game_state == Game_State.Battle:
		switch_state(Game_State.Victory)
	else:
		print_debug("State Error")


func _on_battle_manager_loss() -> void:
	if game_state == Game_State.Battle:
		switch_state(Game_State.Loss)
	else:
		print_debug("State Error")
