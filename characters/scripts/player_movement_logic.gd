extends Node2D
class_name PlayerMovementLogic

## Drives MovingChar for the player: click somewhere, walk there.

@export var moving_char_path: NodePath = ^"../MovingChar"

var _moving_char: MovingChar


func _ready() -> void:
	_moving_char = get_node(moving_char_path)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_moving_char.move_to(get_global_mouse_position())
		get_viewport().set_input_as_handled()
