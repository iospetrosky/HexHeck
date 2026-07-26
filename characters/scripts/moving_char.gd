extends Node2D
class_name MovingChar

## Component that owns *how* the attached character moves. It has no
## opinion on *when* or *where* to go — that decision comes from a
## sibling "movement logic" node (see player_movement_logic.gd /
## other_movement_logic.gd) calling move_to().

signal movement_finished


@export var move_speed: float = 300.0 # pixels per second

var is_moving: bool = false
var identity: String = "Undefined"
var _target: Vector2
var _move_points: float = 128.0 #movement points, assigned when the movement starts
var _movement_logic: Object


func _ready() -> void:
	# The movement logic driving us is always a sibling under our shared
	# parent — either a PlayerMovementLogic or a TurnMovementLogic.
	_movement_logic = get_parent().get_node("MovementLogic")


func move_to(target: Vector2, points: float) -> void:
	if is_moving or points == 0:
		return
	_target = target
	_move_points = points
	is_moving = true

func _physics_process(delta: float) -> void:
	if not is_moving:
		return

	# The character's visuals/collision are siblings of this node, so the
	# thing that actually needs to move is our shared parent.
	var body := get_parent() as CharacterBody2D
	var offset := _target - body.position
	var step := move_speed * delta
	var motion := offset if offset.length() <= step else offset.normalized() * step

	_move_points -= step
	print(_move_points)

	var collision := body.move_and_collide(motion)
	if collision:
		print("collision")
	var reached := collision or body.position.is_equal_approx(_target)
	var out_of_points := _move_points <= 0

	if reached or out_of_points:
		is_moving = false
		# Players keep unspent points to continue moving within the same
		# turn; everyone else's turn ends as soon as they stop.
		var turn_over := out_of_points or identity != 'PLAYER'

		if _movement_logic:
			_movement_logic.movement_points = 0.0 if turn_over else _move_points
		if turn_over:
			movement_finished.emit()
