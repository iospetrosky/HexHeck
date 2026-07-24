extends Node2D
class_name MovingChar

## Component that owns *how* the attached character moves. It has no
## opinion on *when* or *where* to go — that decision comes from a
## sibling "movement logic" node (see player_movement_logic.gd /
## turn_movement_logic.gd) calling move_to().

signal movement_started(target: Vector2)
signal movement_finished

@export var move_speed: float = 300.0 # pixels per second

var is_moving: bool = false

var _target: Vector2


func move_to(target: Vector2) -> void:
	_target = target
	is_moving = true
	movement_started.emit(target)


func _process(delta: float) -> void:
	if not is_moving:
		return

	# The character's visuals/collision are siblings of this node, so the
	# thing that actually needs to move is our shared parent.
	var body := get_parent() as Node2D
	body.position = body.position.move_toward(_target, move_speed * delta)

	if body.position.is_equal_approx(_target):
		is_moving = false
		movement_finished.emit()
