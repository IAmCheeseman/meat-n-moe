extends TileMap


func _ready() -> void:
	var shadow: TileMap = duplicate(8)
	shadow.tile_set = shadow.tile_set.duplicate(true)
	shadow.tile_set.remove_physics_layer(0)
	
	shadow.show_behind_parent = true
	shadow.position.y = 8
	shadow.set_layer_modulate(0, Color(0, 0, 0, 0.5))
	shadow.z_index = -2
	
	add_child(shadow)
	
	for i in shadow.get_children():
		i.queue_free()

