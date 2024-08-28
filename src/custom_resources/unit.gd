class_name Unit
extends Resource

enum Unit_Class {
	None,
	Lord,
}

enum Status_Effect {
	None,
}

@export var name : String
@export var unit_class : Unit_Class
@export var level : int
@export var experience : int
@export var health : int
@export var stats : UnitStats
@export var status : Status_Effect
@export var appearance : SpriteFrames
