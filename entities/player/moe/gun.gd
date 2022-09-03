extends Node2D
class_name Gun

@onready var player := $"../../../"

@onready var shoot_sfx := $ShootSFX

@onready var sprite := $Sprite

@onready var cooldown := $Cooldown

@onready var shoot_position := $ShootPosition


signal selected(node: Node2D)


func _ready() -> void:
	sprite.scale.y = -1

func _physics_process(delta: float) -> void:
	look_at(get_global_mouse_position())
	
	if Input.is_action_pressed("main_action") and _can_shoot():
		emit_signal("selected", self)
		shoot_sfx.play()
		shoot_sfx.pitch_scale = 1 - randf() / 4
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
	
	player.velocity -= dir * 100
	
	GameManager.camera.shake(2, 8, 12, 0.1, 0.1, true, -dir)

