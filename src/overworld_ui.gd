class_name OverworldUi
extends Control

const terrain_data_format : String = "%s\n%s"

@onready var unit_info := $"MarginContainer/unit-box"
@onready var terrain_info := $"MarginContainer2/terrain-box"
@onready var terrain_data := $"MarginContainer2/terrain-box/VBoxContainer/MarginContainer2/HBoxContainer/data"

func show_unit_info() -> void:
	unit_info.show()


func hide_unit_info() -> void:
	unit_info.hide()


func show_terrain_info(defense : int, avoid : int) -> void:
	terrain_data.text = terrain_data_format % [defense, avoid]
	terrain_info.show()
	print("show terrain info")


func hide_terrain_info() -> void:
	terrain_info.hide()
	print("hide terrain info")
