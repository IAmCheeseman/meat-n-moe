extends Node2D

@onready var sprite := $Sprite
@onready var anim := $AnimationPlayer

@onready var cooldown := $Cooldown

@onready var shoot_position := $ShootPosition


func _ready() -> void:
	sprite.scale.y = -1

func _physics_process(delta: float) -> void:
	look_at(get_global_mouse_position())
	
	if Input.is_action_pressed("main_action") and _can_shoot():
		anim.stop()
		anim.play("Shoot")
		_shoot()


func _can_shoot() -> bool:
	return cooldown.is_stopped()


func _shoot() -> void:
	var new_bullet := preload("res://entities/hitscan-bullet/bullet.tscn").instantiate()
	var dir := global_position.direction_to(get_global_mouse_position())
	
	new_bullet.global_position = global_position + dir * shoot_position.position.x
	new_bullet.dir = dir
	new_bullet.damage = 0.5
	new_bullet.shooter = self
	
	GameManager.world.add_child(new_bullet)
	
	cooldown.start()

