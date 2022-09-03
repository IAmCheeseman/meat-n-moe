extends Node2D

@onready var player := $"../../../"

@onready var sprite := $SwingPivot/Sprite
@onready var anim := $AnimationPlayer

@onready var swing_sfx := $SwingSFX
@onready var slice_sfx := $SliceSFX

@onready var swing_pivot := $SwingPivot

@onready var hitbox := $Hitbox

@export var swing_amount := deg_to_rad(90)
@export var swing_pos_amount := 3

var swing_dir = 1

signal selected(node: Node2D)


func _physics_process(delta: float) -> void:
	sprite.rotation = lerp_angle(
		sprite.rotation,
		((PI / 2) * swing_dir),
		16 * delta
	)
	swing_pivot.rotation = lerp_angle(
		sprite.rotation,
		(swing_amount * swing_dir),
		16 * delta
	)
	sprite.position.y = move_toward(
		sprite.position.y,
		swing_pos_amount * swing_dir,
		80 * delta
	)
	
	look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("melee"):
		emit_signal("selected", self)
		_swing()


func _swing() -> void:
	swing_sfx.play()
	swing_sfx.pitch_scale = 1 - randf() / 4
	
	swing_dir = -swing_dir
	sprite.flip_h = !sprite.flip_h
	anim.play("swing")
	
	var dir = global_position.direction_to(get_global_mouse_position())
	
	player.velocity += dir * 100
	
	GameManager.camera.shake(1, 8, 8, 0.2, 0.1, true, dir)


func _on_hit(_area: Area2D) -> void:
	slice_sfx.play()
