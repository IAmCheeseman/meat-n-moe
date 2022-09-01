extends Node2D

@onready var player := $".."
@onready var sprite := $"../Sprite"


func bob(delta: float, speed: float=1.0, amp: float=1.0, height: float=0.0):
	var time = Time.get_unix_time_from_system()
	var sine = sin(time * speed) * amp
	
	sprite.position.y = lerp(sprite.position.y, sine - height, 16 * delta)
	sprite.rotation = move_toward(sprite.rotation, deg_to_rad(player.velocity.x / 25), 16 * delta)


func roll(delta: float, percentage: float) -> void:
	sprite.position.y = move_toward(sprite.position.y, 1, 16 * delta)
	sprite.rotation = percentage * TAU
