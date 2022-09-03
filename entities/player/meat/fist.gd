extends Node2D

@onready var player := $"../../../"

@onready var sprite := $Sprite
@onready var anim := $AnimationPlayer

@onready var swing_sfx := $SwingSFX
@onready var hit_sfx := $HitSFX

@onready var hitbox := $Hitbox

var swing_dir = 1

signal selected(node: Node2D)


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("melee"):
		emit_signal("selected", self)
		_swing()
		look_at(get_global_mouse_position())


func _swing() -> void:
	swing_sfx.play()
	swing_sfx.pitch_scale = 1 - randf() / 4
	
	swing_dir = -swing_dir
	sprite.flip_v = !sprite.flip_v
	anim.play("Punch")
	
	var dir = global_position.direction_to(get_global_mouse_position())
	
	player.velocity += dir * 100
	
	GameManager.camera.shake(1, 8, 8, 0.2, 0.1, true, dir)


func _on_hitbox_hit(_area: Area2D) -> void:
	hit_sfx.play()
