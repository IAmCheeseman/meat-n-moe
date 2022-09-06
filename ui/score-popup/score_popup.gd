extends Label

var _time := 0.0
var _scale_target := Vector2.ONE


func _ready() -> void:
	pivot_offset = size / 2
	rotation = randf_range(-PI / 6, PI / 6)
	scale = Vector2.ONE * 1.5

func _process(delta: float) -> void:
	_time += delta
	position.y -= 5 * delta / _time
	scale = scale.move_toward(_scale_target, 5 * delta)
	
	if _time > 1:
		_scale_target = Vector2.ZERO
		if scale.is_equal_approx(Vector2.ZERO):
			queue_free()


func set_score(amt: int) -> void:
	text = ""
	if amt > 0:
		text = "+"
	text += str(amt)
