extends Control

@onready var unit_infocard = $unit_infocard


func _on_battle_manager_selected_unit(unit: Unit) -> void:
	unit_infocard.set_unit_info(unit)
	unit_infocard.show()


func _on_battle_manager_deselected_unit() -> void:
	unit_infocard.hide()
