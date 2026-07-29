extends CanvasLayer
class_name HUD

@onready var _hit_points_label: Label = $MarginContainer/HBoxContainer/label_hit_points

func connect_to_player(moving_char: MovingChar) -> void:
	moving_char.health_changed.connect(_on_health_changed)
	_on_health_changed(moving_char.hit_points, moving_char.max_hit_points)

func _on_health_changed(current: int, max_hp: int) -> void:
	_hit_points_label.text = "Hit points: %d / %d" % [current, max_hp]
