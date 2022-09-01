extends CharacterBody2D

@onready var sprite := $Sprite
@onready var anim := $AnimationPlayer

@onready var out_timer := $OutTimer

@onready var rc := $RayCast

@export var speed := 300.0
@export var accel := 720.0

var player: Node2D

var _target := Vector2.ZERO


func _ready() -> void:
	velocity = velocity.normalized() * speed

func _physics_process(delta: float) -> void:
	sprite.rotation += 18 * delta
	if out_timer.is_stopped():
		_target = player.global_position
		if global_position.distance_to(_target) < 16:
			velocity = Vector2.ZERO
			anim.play("GoAway")
			return
	else:
		_target = global_position + velocity.normalized() * 1000
	
	rc.target_position = velocity.normalized() * 4
	if rc.is_colliding():
		var normal = rc.get_collision_normal()
		if normal == Vector2.ZERO:
			velocity = -velocity
		else:
			velocity = velocity.bounce(normal)
	
	velocity = velocity.move_toward(
		global_position.direction_to(_target) * speed,
		accel * delta
	)
	
	move_and_slide()
