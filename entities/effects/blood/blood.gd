extends Sprite2D


func _ready() -> void:
	rotation = TAU * randf()
	frame = randi_range(0, hframes - 1)

