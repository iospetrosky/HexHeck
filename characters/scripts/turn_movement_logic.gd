extends Node2D
class_name TurnMovementLogic

## Drives MovingChar for anything that moves on its turn (monsters, allies,
## etc). It doesn't decide *where* to go — a turn manager / AI hands it a
## destination via take_turn(); it just forwards that to MovingChar and
## reports back when the move is done.

signal turn_finished

@export var moving_char_path: NodePath = ^"../MovingChar"

var _moving_char: MovingChar


func _ready() -> void:
	_moving_char = get_node(moving_char_path)
	_moving_char.movement_finished.connect(_on_movement_finished)


func take_turn(target: Vector2) -> void:
	_moving_char.move_to(target)


func _on_movement_finished() -> void:
	turn_finished.emit()
