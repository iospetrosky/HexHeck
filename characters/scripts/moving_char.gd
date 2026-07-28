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
var hit_points: int = 20
var armor_class: int = 5

var _target: Vector2

## draw-order tiers: dead bodies sink to the tiles' level (z_index 0) so
## scene-tree order keeps them above the floor; living characters stay above that
const Z_INDEX_ALIVE = 1
const Z_INDEX_DEAD = 0

## costs of the actions expressed in move_points
const COST_ATTACK = 100
const COST_SWITCH_WEAPON = 15
const COST_QUAFF_POTION = 50
const COST_READ_SCROLL = 50
const COST_PICKUP = 10 #per action, so picking 200 coins costs 10


func _ready() -> void:
	(get_parent() as CanvasItem).z_index = Z_INDEX_ALIVE


func attack(defender: MovingChar) -> bool:
	var roll := randi_range(1, 20)
	if roll < defender.armor_class:
		print("Attack unsuccessfull, rolled ", roll)
		return false

	var damage := randi_range(1, 8)
	defender.hit_points -= damage
	print("Attack successfull for ", damage)
	if defender.hit_points <= 0:
		var body := defender.get_parent() as CharacterBody2D
		var sprite := body.get_node("AnimatedSprite2D") as AnimatedSprite2D
		if not sprite.animation.ends_with("_dead"):
			sprite.animation = sprite.animation + "_dead"
		body.collision_layer = 0
		body.collision_mask = 0
		body.z_index = Z_INDEX_DEAD
	return true


func distance_from_element(elem: Node2D) -> float:
	return global_position.distance_to(elem.global_position)


func move_to(target: Vector2) -> void:
	if is_moving or move_points <= 0:
		return
	_target = target
	is_moving = true

func end_of_turn():
	move_points = 0.0
	is_moving = false
	movement_finished.emit()

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
	# if collision:
	# 	print("collision - remaining points: ", move_points)

	if identity == 'PLAYER':
		if move_points <= 0.0:
			end_of_turn()
		elif collision:
			print("Remaining points: ", move_points)
			var collider := collision.get_collider()
			var collider_identity := ""
			if collider.has_node("MovingChar"):
				collider_identity = collider.get_node("MovingChar").identity

			if collider_identity.begins_with('MONSTER') and move_points >= COST_ATTACK:
				print("The player attacks a monster")
				attack(collider.get_node("MovingChar"))
				end_of_turn()
			else: # another monster or a tile
				end_of_turn()
		## otherwise the player can still act

	if identity.begins_with('MONSTER'):
		if move_points <= 0.0:
			end_of_turn()
		else:
			if collision:
				print("Remaining points: ", move_points)
				var collider := collision.get_collider()
				var collider_identity := ""
				if collider.has_node("MovingChar"):
					collider_identity = collider.get_node("MovingChar").identity

				if collider_identity == 'PLAYER' and move_points >= COST_ATTACK:
					print("The monster attacks the player")
					attack(collider.get_node("MovingChar"))
					end_of_turn()
				elif distance_from_element(collider) < 20:
					# close enough to attack anyway
					print("The monster attacks the player")
					attack(collider.get_node("MovingChar"))
					end_of_turn()
				else:
					end_of_turn()
