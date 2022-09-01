extends Node2D

@onready var player := $"../../../"

@onready var sprite := $Sprite
@onready var anim := $AnimationPlayer

@onready var hitbox := $Hitbox

@export var swing_amount := deg_to_rad(91)
@export var swing_pos_amount := 3

var swing_dir = 1


func _physics_process(delta: float) -> void:
	sprite.rotation = lerp_angle(
		sprite.rotation + PI,
		(swing_amount * swing_dir) + get_local_mouse_position().angle(),
		32 * delta
	) - PI
	sprite.position.y = move_toward(
		sprite.position.y,
		swing_pos_amount * swing_dir,
		80 * delta
	)
	hitbox.rotation = get_local_mouse_position().angle()
	
	if Input.is_action_just_pressed("melee"):
		_swing()


func _swing() -> void:
	swing_dir = -swing_dir
	sprite.flip_v = !sprite.flip_v
	anim.play("swing")
	
	player.velocity += global_position.direction_to(get_global_mouse_position()) * 100
