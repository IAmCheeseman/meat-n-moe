extends Node2D


func _ready() -> void:
	GameManager.world = self
	Pathfinder.generate_astar($Tilemap)
#	update()
#
#func _draw() -> void:
#	var astar = Pathfinder.astar
#
#	var ids = astar.get_point_ids()
#	for i in ids:
#		var connections = astar.get_point_connections(i)
#		for j in connections:
#			draw_line(
#				astar.get_point_position(i),
#				astar.get_point_position(ids[j]),
#				Color.DARK_GREEN
#			)
