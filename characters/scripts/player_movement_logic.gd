extends Node2D
class_name PlayerMovementLogic


@export var moving_char_path: NodePath = "" #assign in GoDot

var _moving_char: MovingChar

func _ready() -> void:
	_moving_char = get_node(moving_char_path)
	_moving_char.identity = 'PLAYER'


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var target := get_global_mouse_position()
		_moving_char.move_to(target)
		#check if the player flips
		var body := get_parent() as CharacterBody2D
		var sprite := body.get_node("AnimatedSprite2D") as AnimatedSprite2D
		sprite.flip_h = target.x < body.global_position.x
		get_viewport().set_input_as_handled()
