extends Control

const hit_data_format := "%s\n%s\n%s"

@onready var left_name := $"contenders/left-contender/name-panel/PanelContainer/name"
@onready var left_hit_data := $"contenders/left-contender/info-panels/data-panel/data-margins/data-split/hit-data"
@onready var left_weapon_icon := $"contenders/left-contender/info-panels/item-panel-offset/item-panel/item-divider/item-spacing/item"
@onready var left_weapon_name := $"contenders/left-contender/info-panels/item-panel-offset/item-panel/item-divider/item-name"
@onready var left_health_number := $"contenders/left-contender/health-panel/health-panel-margins/health-split/hp"
@onready var left_health_bar := $"contenders/left-contender/health-panel/health-panel-margins/health-split/hp-bar-spacing/hp-bar"

@onready var right_name := $"contenders/right-contender/name-panel/PanelContainer/name"
@onready var right_hit_data := $"contenders/right-contender/info-panels/data-panel/MarginContainer/HBoxContainer/hit-data"
@onready var right_weapon_icon := $"contenders/right-contender/info-panels/MarginContainer/item-panel/HBoxContainer/MarginContainer/item"
@onready var right_weapon_name := $"contenders/right-contender/info-panels/MarginContainer/item-panel/HBoxContainer/item-name"
@onready var right_health_number := $"contenders/right-contender/health-panel/MarginContainer/HBoxContainer/hp"
@onready var right_health_bar := $"contenders/right-contender/health-panel/MarginContainer/HBoxContainer/MarginContainer/hp-bar"

func set_left_data_from_unit(unit: Unit, opponent: Unit, terrain: int) -> void:
	left_name.text = unit.name
	left_hit_data.text = hit_data_format % [unit.get_accuracy(opponent, terrain), unit.get_attack_power(false, false), unit.weapon.crit_chance]
	left_weapon_name.text = "Sword"
	set_left_health_from_unit(unit)


func set_left_health_from_unit(unit: Unit) -> void:
	left_health_number.text = str(unit.health)
	left_health_bar.value = remap(unit.health, 0, unit.stats.max_health, 0, 76)


func set_right_data_from_unit(unit: Unit, opponent: Unit, terrain: int) -> void:
	right_name.text = unit.name
	right_hit_data.text = hit_data_format % [unit.get_accuracy(opponent, terrain), unit.get_attack_power(false, false), unit.weapon.crit_chance]
	right_weapon_name.text = unit.weapon.name
	set_right_health_from_unit(unit)


func set_right_health_from_unit(unit: Unit) -> void:
	right_health_number.text = str(unit.health)
	right_health_bar.value = remap(unit.health, 0, unit.stats.max_health, 0, 76)
