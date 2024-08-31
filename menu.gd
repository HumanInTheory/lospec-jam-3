class_name MenuUi
extends PanelContainer

signal clicked_away
signal clicked_item(item)

enum Menu_Options {
	Nothing,
	Attack,
	End_Turn,
	Seige,
	Wait,
}

const Item_Height : float = 10.5

var item_count : int = 3
var disabled : bool = true
var current_items : PackedInt32Array

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("touch"):
		on_touch(get_global_mouse_position())


func on_touch(pixel: Vector2) -> void:
	print("on menu touch")
	if pixel.x < position.x or pixel.y < position.y or \
	pixel.x > position.x + size.x or pixel.y > position.y + size.y:
		hide_menu()
		clicked_away.emit()
		return
	
	var item : int = int((pixel.y - position.y - 2.5) / Item_Height)
	print_debug(current_items[item])
	hide_menu()
	clicked_item.emit(current_items[item])


func show_menu(location : Vector2, items : PackedInt32Array):
	position = location
	current_items = items
	$"item-text".text = ""
	for item in items:
		$"item-text".text += Menu_Options.keys()[item].replace("_", " ") + "\n"
	item_count = len(items)
	reset_size()
	show()
	disabled = false


func hide_menu():
	hide()
	disabled = true
