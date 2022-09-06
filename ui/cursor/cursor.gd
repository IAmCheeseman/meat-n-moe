extends CanvasLayer

@onready var _cursor := $Node


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _process(delta: float) -> void:
	_cursor.global_position = $"/root".get_mouse_position()
	
	var offsets = [
		Vector2( 3, -3),
		Vector2( 3,  3),
		Vector2(-3,  3),
		Vector2(-3, -3),
	]
	for i in _cursor.get_children():
		i.offset = i.offset.move_toward(offsets[i.get_index()], 5 * delta)


func scale_up(by: float, cap:=7.0) -> void:
	for i in _cursor.get_children():
		i.offset *= by
		i.offset = i.offset.limit_length(cap)
