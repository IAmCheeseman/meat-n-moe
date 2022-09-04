extends Sprite2D


func _ready() -> void:
	seed(1)
	frame = hframes * randf()
