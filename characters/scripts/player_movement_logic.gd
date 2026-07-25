extends Node2D
class_name PlayerMovementLogic

const DEF_MOVE_POINTS = 128

@export var moving_char_path: NodePath = "" #assign in GoDot

var _moving_char: MovingChar
var movement_points: float


func _ready() -> void:
	movement_points = DEF_MOVE_POINTS
	_moving_char = get_node(moving_char_path)



func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_moving_char.move_to(get_global_mouse_position(), movement_points, self)
		get_viewport().set_input_as_handled()
