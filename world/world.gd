extends Node2D

@onready var viewport = $CanvasLayer/ViewportContainer/Viewport

func _ready() -> void:
	GameManager.world = viewport
	GameManager.stage_start_score = GameManager.score
	Pathfinder.generate_astar($Tilemap)
	
	for i in get_children():
		if !i is CanvasLayer:
			remove_child(i)
			viewport.add_child(i)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("reset"):
		get_tree().root.set_input_as_handled()
		get_tree().reload_current_scene()
