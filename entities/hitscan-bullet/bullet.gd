extends Node2D

@onready var rc := $RayCast

@export var damage := 1.0
@export var dir := Vector2.RIGHT

var shooter: Node2D

var _end_position := Vector2.ZERO

func _ready() -> void:
	rc.target_position = dir.normalized() * 1000
	rc.force_raycast_update()
	_shoot()

func _shoot() -> void:
	_end_position = dir.normalized() * 1000
	if rc.is_colliding():
		_end_position = to_local(rc.get_collision_point())
		
		var obj: Node2D = rc.get_collider()
		if !obj.is_in_group("hurtbox"):
			return
		obj.take_damage(damage, rc.target_position.normalized())
	update()

func _draw() -> void:
	draw_line(Vector2.ZERO, _end_position, Color.WHITE)
