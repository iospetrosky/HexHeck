extends Node2D
class_name TurnMovementLogic

## Drives MovingChar for anything that moves on its turn (monsters, allies,
## etc). It doesn't decide *where* to go — a turn manager / AI hands it a
## destination via take_turn(); it just forwards that to MovingChar and
## reports back when the move is done.

@export var moving_char_path: NodePath = "" #assign in GoDot
var movement_points: float

var _moving_char: MovingChar

func set_move_points(pp: float) -> void:
	movement_points = pp

func _ready() -> void:
	_moving_char = get_node(moving_char_path)
	_moving_char.identity = 'MONSTER' #the creator of the instance can be more specific


func take_turn(player: CharacterBody2D) -> void:
	# monsters try to move towards the player for the maximum amount
	# of hit points (unless they collide)
	# sprite is flipped horizontally if needed
	var body := get_parent() as CharacterBody2D
	var sprite := body.get_node("AnimatedSprite2D") as AnimatedSprite2D
	sprite.flip_h = player.global_position.x < body.global_position.x
	_moving_char.move_to(player.global_position, movement_points)
