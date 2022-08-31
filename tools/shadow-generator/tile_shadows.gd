extends TileMap


func _ready() -> void:
	var shadow: TileMap = duplicate(8)
	shadow.tile_set = shadow.tile_set.duplicate(true)
	shadow.tile_set.remove_physics_layer(0)
	
	shadow.show_behind_parent = true
	shadow.position.y = 8
	shadow.modulate = Color(0, 0, 0, 0.5)
	shadow.z_index = -2
	
	add_child(shadow)

