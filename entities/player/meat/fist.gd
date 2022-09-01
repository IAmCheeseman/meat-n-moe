extends Node2D

@onready var player := $"../../../"

@onready var sprite := $Sprite
@onready var anim := $AnimationPlayer

@onready var hitbox := $Hitbox


var swing_dir = 1


func _physics_process(delta: float) -> void:
	look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("melee"):
		_swing()


func _swing() -> void:
	swing_dir = -swing_dir
	sprite.flip_v = !sprite.flip_v
	anim.play("Punch")
	
	player.velocity += global_position.direction_to(get_global_mouse_position()) * 100
