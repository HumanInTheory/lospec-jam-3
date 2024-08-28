@tool
class_name UnitOld
extends Path2D

signal finished_walking

@export var grid : Grid = preload("res://src/world_grid.tres")

@export var speed : int = 6

@export var skin : SpriteFrames :
	get:
		return skin
	set(new_tex):
		skin = new_tex
		if not sprite:
			await self.ready
			sprite.sprite_frames = skin

@export var path_speed : int = 50

@export var army : int = 0

var cell_location := Vector2i(0, 0) :
	set(new_cell):
		cell_location = grid.clamp_cell_location(new_cell)

var is_selected : bool = false :
	set(new_state):
		is_selected = new_state
		if new_state:
			sprite.play("selected")
		elif not has_acted:
			sprite.play("idle")

var is_walking : bool = false :
	set(new_state):
		is_walking = new_state
		set_process(is_walking)

var has_walked : bool = false

var path_delta := Vector2(0, 0)
var path_previous := Vector2(0, 0)

var has_acted : bool = false :
	set(status):
		has_acted = status
		if status:
			sprite.play("disabled")
		else:
			sprite.play("idle")

@onready var sprite : AnimatedSprite2D = $PathFollow2D/Sprite2D
@onready var path_follow : PathFollow2D = $PathFollow2D

func _ready() -> void:
	set_process(false)
	
	cell_location = grid.pixel_to_cell_location(position)
	position = grid.cell_to_pixel_location(cell_location)
	
	sprite.play("idle")
	
	if not Engine.is_editor_hint():
		curve = Curve2D.new()


func _process(delta: float) -> void:
	path_follow.progress += path_speed * delta
	
	path_delta = path_follow.transform.origin - path_previous
	path_previous = path_follow.transform.origin
	
	if path_delta.x > 0:
		sprite.play("walk_side")
		sprite.flip_h = false
	elif path_delta.x < 0:
		sprite.play("walk_side")
		sprite.flip_h = true
	elif path_delta.y > 0:
		sprite.play("walk_down")
		sprite.flip_h = false
	elif path_delta.y < 0:
		sprite.play("walk_up")
		sprite.flip_h = false
	
	if path_follow.progress_ratio >= 1:
		is_walking = false
		has_walked = true
		path_follow.progress = 0
		position = grid.cell_to_pixel_location(cell_location)
		curve.clear_points()
		sprite.play("idle")
		finished_walking.emit()


func walk_path(path: Array[Vector2i]) -> void:
	if path.is_empty():
		return
	
	curve.add_point(Vector2i(0, 0))
	for point in path:
		curve.add_point(grid.cell_to_pixel_location(point) - position)
	
	cell_location = path[-1]
	is_walking = true
