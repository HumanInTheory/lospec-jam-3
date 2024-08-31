class_name Unit
extends Resource

enum Unit_Class {
	None,
	Lord,
}

enum Status_Effect {
	None,
}

enum Unit_State {
	None,
	Fresh,
	Moving,
	Moved,
	Acting,
	Acted,
}

@export var name : String
@export var unit_class : Unit_Class
@export var level : int
@export var experience : int
@export var health : int
@export var stats : UnitStats
@export var weapon : UnitWeapon
@export var status : Status_Effect
@export var appearance : SpriteFrames
@export var attack_frames : SpriteFrames
@export var info_sprite : Texture2D
var game_piece : AnimatedSprite2D
var grid : Grid
var current_state : Unit_State
var target_cell : Vector2i


func set_grid(new_grid : Grid) -> void:
	grid = new_grid


func enter_state(new_state : Unit_State, old_state : Unit_State) -> void:
	print_debug("Entering " + Unit_State.keys()[new_state])
	
	match new_state:
		Unit_State.Fresh:
			game_piece.animation = "idle"
		Unit_State.Moving:
			game_piece.position = grid.cell_to_pixel_location(target_cell)
			switch_state(Unit_State.Moved)
		Unit_State.Acting:
			switch_state(Unit_State.Acted)
		Unit_State.Acted:
			game_piece.animation = "disabled"


func exit_state(old_state : Unit_State, new_state : Unit_State) -> void:
	print_debug("Exiting " + Unit_State.keys()[old_state])
	
	match old_state:
		Unit_State.None:
			pass


func switch_state(new_state : Unit_State) -> void:
	exit_state(current_state, new_state)
	var old_state = current_state
	current_state = new_state
	enter_state(new_state, old_state)


func refresh() -> void:
	switch_state(Unit_State.Fresh)


func can_move() -> bool:
	return current_state == Unit_State.Fresh


func move_unit(new_cell : Vector2i) -> void:
	if current_state == Unit_State.Fresh:
		target_cell = new_cell
		switch_state(Unit_State.Moving)
	else:
		print_debug("Moved when unable")


func can_act() -> bool:
	return current_state != Unit_State.Acted


func commit_act() -> void:
	if current_state == Unit_State.Acted:
		print_debug("Moved when unable")
	
	switch_state(Unit_State.Acting)


func get_attack_speed() -> int:
	return stats.speed - (weapon.weight - stats.constitution if weapon.weight > stats.constitution else 0)


func double_attack_against(target: Unit) -> bool:
	return stats.speed - 4 > target.stats.speed


func get_hit_rate() -> int:
	return weapon.hit_chance + stats.dexterity


func get_avoid(terrain: int) -> int:
	match terrain:
		Level.Cell_Type.Trees:
			return get_attack_speed() + 20
	
	return get_attack_speed()


func get_accuracy(target: Unit, terrain: int) -> int:
	return clampi(get_hit_rate() - target.get_avoid(terrain), 0, 100)


func get_attack_power(effective: bool, crit: bool) -> int:
	return (stats.strength + weapon.might * (3 if effective else 1)) * (2 if crit else 1)


func get_defense_power() -> int:
	return stats.defense


func successful_hit() -> bool:
	return randi_range(0, 100) <= weapon.hit_chance


func does_crit() -> bool:
	return randi_range(0, 100) <= weapon.crit_chance


func take_damage(amount: int) -> void:
	var result := amount - get_defense_power()
	health -= (result if result > 0 else 0)
	if health < 0:
		health = 0
