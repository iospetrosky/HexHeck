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
var move_points: float = 0.0 #the single source of truth for this character's remaining movement budget

var _target: Vector2


func move_to(target: Vector2) -> void:
	if is_moving or move_points <= 0:
		return
	_target = target
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

	move_points -= step
	#print(move_points)

	var collision := body.move_and_collide(motion)
	if collision:
		print("collision - remaining points: ", move_points)
	var reached := collision or body.position.is_equal_approx(_target)
	var out_of_points := move_points <= 0

	if reached or out_of_points:
		is_moving = false
		# Players keep unspent points to continue moving within the same
		# turn; everyone else's turn ends as soon as they stop.
		var turn_over := out_of_points or identity != 'PLAYER'

		if turn_over:
			move_points = 0.0
			movement_finished.emit()
