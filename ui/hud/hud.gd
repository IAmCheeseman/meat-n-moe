extends Control

@onready var score = %ScoreNumber


func _ready() -> void:
	GameManager.connect("score_changed", Callable(self, "_on_score_changed"))
	_on_score_changed()


func _process(delta: float) -> void:
	score.scale = score.scale.move_toward(Vector2.ONE, 5 * delta)


func _on_score_changed() -> void:
	score.text = str(GameManager.score)
	score.scale = Vector2.ONE * 1.5
