extends Node2D
"""
Keeping track of branches
main: basically all AI generated - dev stopped becuase I was not learning
-> slow: a slow approach, function by function, to understand the connections
   of the nodes - implements the turn based concept

"""
const DEF_MOVE_POINTS = 130 #the equivalent of a tile in pixel, circa
## costs of the actions expressed in move_points
const COST_ATTACK = 60
const COST_SWITCH_WEAPON = 15
const COST_QUAFF_POTION = 50
const COST_READ_SCROLL = 50
const COST_PICKUP = 10 #per action, so picking 200 coins costs 10


const _PLAYER_TURN = 1
const _MONSTER_TURN = 2



@onready var the_player: CharacterBody2D = $Player
@onready var _status = _PLAYER_TURN
@onready var _is_monster_moving = false

const MONSTER_SCENES: Array[PackedScene] = [
	preload("res://characters/monster_small.tscn"),
	preload("res://characters/monster_medium.tscn"),
]
const MONSTER_COUNT := 10


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	the_player.get_node("MovingChar").movement_finished.connect(_on_movement_finished.bind(the_player))
	the_player.get_node("MovingChar").move_points = DEF_MOVE_POINTS
	_spawn_monsters()


func _on_movement_finished(_mover: CharacterBody2D) -> void:
	var id = _mover.get_node("MovingChar").identity
	print(id, " has finished turn")
	if id == 'PLAYER':
		for monster in get_tree().get_nodes_in_group("monsters"):
			monster.get_node("MovingChar").move_points = DEF_MOVE_POINTS
		_status = _MONSTER_TURN
		_is_monster_moving = false
	if id == 'MONSTER':
		_is_monster_moving = false

func _spawn_monsters() -> void:
	var soft_items := $Dungeon/SoftItems as TileMapLayer
	var hard_items := $Dungeon/HardItems as TileMapLayer

	var blocked_cells := {}
	for cell in hard_items.get_used_cells():
		blocked_cells[cell] = true

	var open_cells: Array[Vector2i] = []
	for cell in soft_items.get_used_cells():
		if not blocked_cells.has(cell):
			open_cells.append(cell)
	open_cells.shuffle()

	for i in range(min(MONSTER_COUNT, open_cells.size())):
		var monster := (MONSTER_SCENES.pick_random() as PackedScene).instantiate()
		add_child(monster)
		monster.add_to_group("monsters")
		monster.global_position = soft_items.to_global(soft_items.map_to_local(open_cells[i]))
		var moving_char := monster.get_node("MovingChar")
		moving_char.identity = 'MONSTER' #here's where you can set the type of monster
		moving_char.movement_finished.connect(_on_movement_finished.bind(monster))
		moving_char.move_points = 0 #initially they can't move


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _status == _MONSTER_TURN and not _is_monster_moving:
		#Finding the first monster with movement points and let it take its turn
		var found = false
		for monster in get_tree().get_nodes_in_group("monsters"):
			if monster.get_node("MovingChar").move_points > 0:
				found = true
				_is_monster_moving = true
				monster.get_node("MovementLogic").take_turn(the_player)
				break
		if not found:
			_status = _PLAYER_TURN
			the_player.get_node("MovingChar").move_points = DEF_MOVE_POINTS
