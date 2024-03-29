extends Node2D
class_name BoomerangControls

@export var cooldown := 2

var timer: Timer

signal selected(node: Node2D)


func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = cooldown
	timer.one_shot = true
	
	add_child(timer)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("secondary_action") and timer.is_stopped():
		emit_signal("selected", self)
		
		var new_boomerang = preload("res://entities/player/moe/boomerang_projectile.tscn").instantiate()
		var dir = global_position.direction_to(get_global_mouse_position())
		new_boomerang.player = $".."
		new_boomerang.global_position = global_position + dir * 16
		new_boomerang.velocity = dir
		
		GameManager.world.add_child(new_boomerang)
		
		timer.start()
		
		GameManager.camera.shake(1, 8, 8, 0.4, 0.1, true)
