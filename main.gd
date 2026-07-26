extends Node2D

const DEF_MOVE_POINTS = 128 #the equivalent of a tile in pixel

@onready var the_player: CharacterBody2D = $Player


const MONSTER_SCENES: Array[PackedScene] = [
	preload("res://characters/monster_small.tscn"),
	preload("res://characters/monster_medium.tscn"),
]
const MONSTER_COUNT := 10


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	the_player.get_node("MovingChar").movement_finished.connect(_on_movement_finished.bind(the_player))
	_spawn_monsters()


func _on_movement_finished(_mover: CharacterBody2D) -> void:
	print(_mover.get_node("MovingChar").identity, " has finished turn")
	pass #TODO: react to a character's turn ending


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
		monster.global_position = soft_items.to_global(soft_items.map_to_local(open_cells[i]))
		var moving_char := monster.get_node("MovingChar")
		moving_char.identity = 'MONSTER' #here's where you can set the type of monster
		moving_char.movement_finished.connect(_on_movement_finished.bind(monster))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
