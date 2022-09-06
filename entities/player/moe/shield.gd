extends Node2D

@onready var pivot := $Pivot

@export var shield_dist := 8.0

signal selected(node: Node2D)


func _process(delta: float) -> void:
	var angle = global_position.angle_to_point(get_global_mouse_position())
	var pos = Vector2.RIGHT.rotated(angle) * shield_dist
	pivot.position = pos * (-global_scale if pos.x > 0 else 1)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("secondary_move"):
		emit_signal("selected", self)
		get_tree().root.set_input_as_handled()
	if event.is_action_released("secondary_move"):
		hide()
		get_tree().root.set_input_as_handled()
