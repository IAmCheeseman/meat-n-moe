extends Node2D

var world: Viewport
var camera: CustomCamera

var score := 0:
	set(value):
		score = value
		emit_signal("score_changed")
var stage_start_score := 0

var enemy_callouts := 0


signal score_changed


func _ready() -> void:
	z_index = 4000


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func add_score_popup(at: Node2D, score: int) -> void:
	var new_popup := preload("res://ui/score-popup/score_popup.tscn").instantiate()
	new_popup.global_position = at.global_position - camera.global_position + get_viewport_rect().end / 2
	new_popup.set_score(score)
	world.add_sibling(new_popup)
