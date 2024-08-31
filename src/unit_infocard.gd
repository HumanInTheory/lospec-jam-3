extends MarginContainer

const health_data_format : String = "HP %s/%s"

@onready var portrait := $"unit-box/HBoxContainer/MarginContainer/unit-portrait"
@onready var unit_name := $"unit-box/HBoxContainer/MarginContainer2/VBoxContainer/name"
@onready var health_text := $"unit-box/HBoxContainer/MarginContainer2/VBoxContainer/health"

func set_unit_info(unit : Unit) -> void:
	portrait.texture = unit.info_sprite
	unit_name.text = unit.name
	health_text.text = health_data_format % [unit.health, unit.stats.max_health]
