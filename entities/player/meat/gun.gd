extends Gun


func _shoot() -> void:
	var mods = [0, PI / 18, -PI / 18, PI / 14, -PI / 14]
	
	for i in 5:
		var new_bullet := preload("res://entities/hitscan-bullet/bullet.tscn").instantiate()
		var dir := global_position.direction_to(get_global_mouse_position())
		dir = dir.rotated(mods[i])
		
		new_bullet.global_position = global_position + dir * 8
		new_bullet.dir = dir
		new_bullet.damage = 0.32
		new_bullet.shooter = self
		
		GameManager.world.add_child(new_bullet)
		
		cooldown.start()
		
		player.velocity -= dir * 50
		
		GameManager.camera.shake(2, 8, 8, 0.6, 0.1, true)
		
		get_tree().call_group("enemy", "recieve_player_callout", self, self, GameManager.enemy_callouts, 148)
		GameManager.enemy_callouts += 1
		
#		Cursor.scale_up(10)
