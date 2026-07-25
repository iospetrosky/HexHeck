extends Node2D
class_name MovingChar

## Component that owns *how* the attached character moves. It has no
## opinion on *when* or *where* to go — that decision comes from a
## sibling "movement logic" node (see player_movement_logic.gd /
## other_movement_logic.gd) calling move_to().

#signal movement_finished


@export var move_speed: float = 300.0 # pixels per second

var is_moving: bool = false

var _target: Vector2
var _move_points: float = 128.0 #movement points, assigned when the movement starts
var _points_owner: Object


func move_to(target: Vector2, points: float, points_owner: Object = null) -> void:
	if is_moving:
		return
	_target = target
	_move_points = points
	_points_owner = points_owner
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

	if collision or body.position.is_equal_approx(_target):
		is_moving = false
		if _points_owner:
			_points_owner.movement_points = _move_points

	if _move_points <= 0:
		is_moving = false
		if _points_owner:
			_points_owner.movement_points = 0
		#movement_finished.emit()
