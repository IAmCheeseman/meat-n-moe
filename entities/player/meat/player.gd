extends CharacterBody2D

@onready var sprite := $Sprite
@onready var blood := $Sprite/Blood
@onready var anim := $AnimationPlayer
@onready var shadow = $Shadow
@onready var health_vignette = $CanvasLayer/Health

@onready var weapons = $Sprite/Weapons

@onready var damage_manager := $DamageManager

@onready var teleport_rc := $Collision/TeleportRayCast

@export_category("Movement")
@export var speed := 150.0
@export var accel := 300.0
@export var frict := 300.0

@export_subgroup("Teleport", "teleport")
@export var teleport_distance := 32.0

@export_category("Health")
@export var regen_rate := 1.0

@export_category("Blood")
@export var blood_reduce_rate := 0.2

var _s_default = State.new(
	"default",
	Callable(self, "_default_process")
)
var _state_machine = StateMachine.new(_s_default)

var current_weapon := 0

var target_hook_position := Vector2.ZERO


func add_blood(enemy: Node2D) -> void:
	if enemy.global_position.distance_to(global_position) < 32:
		blood.material.set_shader_uniform(
			"amount",
			clamp(blood.material.get_shader_uniform("amount") + 0.2, 0.0, 0.8)
		)

func _get_input_dir() -> Vector2:
	return Input.get_vector("left", "right", "up", "down")

func _is_state(to: String) -> bool:
	return _state_machine.get_state_name() == to



func _ready() -> void:
	shadow.texture = ShadowGenerator.generate(sprite.texture.get_width() / sprite.hframes)

func _physics_process(delta: float) -> void:
	_state_machine.process(delta)
	
	sprite.scale.x = 1 if get_local_mouse_position().x < 0 else -1
	
	damage_manager.health += delta * regen_rate
	damage_manager.health = clamp(damage_manager.health, 0, damage_manager.max_health)
	var percentage_down = 1 - damage_manager.health / damage_manager.max_health
	health_vignette.material.set_shader_uniform("amp", percentage_down)
	
	blood.frame = sprite.frame
	if velocity != Vector2.ZERO:
		blood.material.set_shader_uniform(
			"amount",
			clamp(blood.material.get_shader_uniform("amount") - blood_reduce_rate * delta, 0.0, 0.8)
		)
		anim.play("meat_animations/Walk")
	else:
		anim.play("meat_animations/Idle")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("roll"):
		var dir = _get_input_dir()
		var teleport_target_position = global_position + dir * teleport_distance
		
		for i in 24:
			var new_blood = preload("res://entities/effects/blood/blood.tscn").instantiate()
			var blood_dir = Vector2.RIGHT.rotated(TAU * randf())
			new_blood.global_position = global_position + blood_dir * randf_range(0, 32)
			GameManager.world.add_child(new_blood)
		
		blood.material.set_shader_uniform(
			"amount",
			clamp(blood.material.get_shader_uniform("amount") + 0.2, 0.0, 0.8)
		)
		
		global_position = teleport_target_position


func _default_process(delta: float) -> void:
	var input_dir := _get_input_dir()
	var movement_delta := accel if input_dir.dot(velocity) > 0 else frict
	
	velocity = velocity.move_toward(input_dir * speed, movement_delta * delta)
	
	move_and_slide()


func _on_damage_manager_dead() -> void:
	get_tree().reload_current_scene()
