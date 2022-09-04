extends Node2D

var target_node: Node2D

@onready var level_select := $LevelSelect
@onready var anim := $AnimationPlayer


func _on_new_node_selected(node: Node2D) -> void:
	await FrameTimer.physics_timer(self).timeout
	
	target_node = node
	
	level_select.set_text(node)


func _unhandled_input(event: InputEvent) -> void:
	if anim.current_animation == "In":
		if event.is_action_pressed("skip"):
			anim.play("RESET")
		get_tree().root.set_input_as_handled()

func _process(delta: float) -> void:
	if target_node:
		position.y = ceil(lerp(position.y, target_node.position.y - 14, 15 * delta))
