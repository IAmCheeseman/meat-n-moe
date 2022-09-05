extends Sprite2D


func _ready() -> void:
	seed(1)
	frame = int(float(hframes )* randf())
