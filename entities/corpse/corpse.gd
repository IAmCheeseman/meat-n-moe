extends CharacterBody2D

@onready var sprite := $Sprite
@onready var shadow := $Shadow

@onready var rc := $RayCast2D


func set_sprite(texture: Texture) -> void:
	sprite.texture = texture
	sprite.offset.y = -sprite.texture.get_height() / 2
	shadow.texture = ShadowGenerator.generate(texture.get_width())

func _physics_process(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, 100 * delta)
	
	rc.target_position = velocity.normalized() * 15
	if rc.is_colliding():
		velocity = velocity.bounce(rc.get_collision_normal())
		rc.target_position = velocity.normalized() * 15
		rc.force_raycast_update()
	
	move_and_slide()
