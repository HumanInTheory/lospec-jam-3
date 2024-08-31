class_name Level
extends TileMapLayer

enum Cell_Type {
	Solid,
	Grass,
	Trees,
	Road,
}

@export var player_spawns : Array[Marker2D]
@export var enemy_spawns : Array[Marker2D]
@export var enemies : Array[Unit]
