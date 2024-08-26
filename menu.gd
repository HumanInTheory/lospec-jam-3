class_name MenuUi
extends PanelContainer

signal clicked_away
signal clicked_item(item)

const Item_Height : float = 10.5

var item_count : int = 3
var disabled : bool = true

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
	print(item)
	hide_menu()
	clicked_item.emit(item)


func show_menu(location : Vector2, items : PackedStringArray):
	position = location
	$"item-text".text = "\n".join(items)
	item_count = len(items)
	reset_size()
	show()
	disabled = false


func hide_menu():
	hide()
	disabled = true
