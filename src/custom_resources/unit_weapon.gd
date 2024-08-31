class_name UnitWeapon
extends Resource

enum Weapon_Type {
	None,
	Sword,
}

@export var name : String
@export var type : Weapon_Type
@export var range : int
@export var weight : int
@export var might : int
@export var hit_chance : int
@export var crit_chance : int
