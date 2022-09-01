extends Node2D
class_name BoomerangControls


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("secondary_action"):
		var new_boomerang = preload("res://entities/player/moe/boomerang_projectile.tscn").instantiate()
		new_boomerang.player = $".."
		new_boomerang.global_position = global_position
		new_boomerang.velocity = global_position.direction_to(get_global_mouse_position())
		
		GameManager.world.add_child(new_boomerang)
