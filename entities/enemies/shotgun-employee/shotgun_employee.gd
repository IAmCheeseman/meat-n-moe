extends Employee


func _shoot() -> void:
	var mods = [0, 0.5, 1]
	for i in 3:
		var new_bullet := preload("res://entities/hitscan-bullet/bullet.tscn").instantiate()
		var dir := global_position.direction_to(_player.global_position)
		dir = dir.rotated(randf_range(-PI / 6, PI / 6) * mods[i])
		
		new_bullet.global_position = global_position + dir * 8
		new_bullet.dir = dir
		new_bullet.shooter = self
		
		GameManager.world.add_child(new_bullet)
