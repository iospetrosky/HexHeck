extends Node2D
class_name TurnMovementLogic

## Drives MovingChar for anything that moves on its turn (monsters, allies,
## etc). It doesn't decide *where* to go — a turn manager / AI hands it a
## destination via take_turn(); it just forwards that to MovingChar and
## reports back when the move is done.

@export var moving_char_path: NodePath = "" #assign in GoDot

var _moving_char: MovingChar

func _ready() -> void:
	_moving_char = get_node(moving_char_path)
	_moving_char.identity = 'MONSTER' #the creator of the instance can be more specific


func take_turn(target: Vector2, player: CharacterBody2D) -> void:
	pass
	#_moving_char.move_to(target)
