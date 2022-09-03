extends Gun


func _shoot() -> void:
	var mods = [0, 0.25, 1, 1]
	
	for i in 4:
		var new_bullet := preload("res://entities/hitscan-bullet/bullet.tscn").instantiate()
		var dir := global_position.direction_to(get_global_mouse_position())
		dir = dir.rotated(randf_range(-PI / 8, PI / 8) * mods[i])
		
		new_bullet.global_position = global_position + dir * 8
		new_bullet.dir = dir
		new_bullet.damage = 0.5
		new_bullet.shooter = self
		
		GameManager.world.add_child(new_bullet)
		
		cooldown.start()
		
		player.velocity -= dir * 50
		
		GameManager.camera.shake(2, 8, 8, 0.6, 0.1, true)
