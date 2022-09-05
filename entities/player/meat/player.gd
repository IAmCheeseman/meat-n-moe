extends CharacterBody2D

@onready var sprite := $Sprite
@onready var blood := $Sprite/Blood
@onready var anim := $AnimationPlayer
@onready var blood_particles := $Blood
@onready var shadow := $Shadow
@onready var health_vignette := $CanvasLayer/Health

@onready var teleport_sfx := $TeleportSFX

@onready var weapons := $Sprite/Weapons

@onready var damage_manager := $DamageManager

@onready var teleport_rc := $Collision/TeleportRayCast

@export_category("Movement")
@export var speed := 150.0
@export var accel := 300.0
@export var frict := 300.0

@export_subgroup("Slide", "slide")
@export var slide_speed := 150.0
@export var slide_accel := 300.0

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
var _s_slide = State.new(
	"slide",
	Callable(self, "_slide_process"),
	Callable(self, "_slide_start")
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
	var angle := 0.0
	for i in 4:
		var new_rc = RayCast2D.new()
		new_rc.target_position = Vector2.RIGHT.rotated(angle) * 3
		teleport_rc.add_child(new_rc)
		angle += PI / 2

func _physics_process(delta: float) -> void:
	_state_machine.process(delta)
	
	sprite.scale.x = 1 if get_local_mouse_position().x < 0 else -1
	
	damage_manager.health += delta * regen_rate
	damage_manager.health = clamp(damage_manager.health, 0, damage_manager.max_health)
	var percentage_down = 1 - damage_manager.health / damage_manager.max_health
	health_vignette.material.set_shader_uniform("amp", percentage_down)
	
	blood.frame = sprite.frame


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("roll"):
		_teleport()
		get_tree().root.set_input_as_handled()
	if event.is_action_pressed("secondary_move") and _state_machine.get_state_name() == "default":
		_state_machine.change_state(_s_slide)
		get_tree().root.set_input_as_handled()
	if event.is_action_released("secondary_move") and _state_machine.get_state_name() == "slide":
		_state_machine.change_state(_s_default)
		get_tree().root.set_input_as_handled()


func _teleport() -> void:
	var dir = _get_input_dir()
	var dist = teleport_distance * (1.2 if _state_machine.get_state_name() == "slide" else 1)
	var teleport_target_position = global_position + dir * dist
	
	teleport_rc.global_position = teleport_target_position
	for rc in teleport_rc.get_children():
		rc.force_raycast_update()
		if rc.is_colliding():
			return
	
	for i in 24:
		var new_blood = preload("res://entities/effects/blood/blood.tscn").instantiate()
		var blood_dir = Vector2.RIGHT.rotated(TAU * randf())
		new_blood.global_position = global_position + blood_dir * randf_range(0, 32)
		GameManager.world.add_child(new_blood)
	
	blood.material.set_shader_uniform(
		"amount",
		clamp(blood.material.get_shader_uniform("amount") + 0.2, 0.0, 0.8)
	)
	
	blood_particles.restart()
	
	damage_manager.take_damage(damage_manager.health * 0.4, Vector2.ZERO)
	
	global_position = teleport_target_position
	
	GameManager.camera.shake(2, 8, 8, 0.8, 0.1, true)
	
	teleport_sfx.play()


func _default_process(delta: float) -> void:
	var input_dir := _get_input_dir()
	var movement_delta := accel if input_dir.dot(velocity) > 0 else frict
	
	velocity = velocity.move_toward(input_dir * speed, movement_delta * delta)
	
	move_and_slide()
	
	if velocity != Vector2.ZERO:
		blood.material.set_shader_uniform(
			"amount",
			clamp(blood.material.get_shader_uniform("amount") - blood_reduce_rate * delta, 0.0, 0.8)
		)
		anim.play("meat_animations/Walk", -1, velocity.length() / 100)
	else:
		anim.play("meat_animations/Idle")


func _slide_start() -> void:
	velocity = _get_input_dir() * slide_speed * 1.5

func _slide_process(delta: float) -> void:
	anim.play("meat_animations/Slide")
	
	var input_dir := _get_input_dir()
	
	if (
		velocity.dot(input_dir) < 0
		or input_dir == Vector2.ZERO
		or velocity.length() < 100
	):
		_state_machine.change_state(_s_default)
	
	GameManager.camera.shake(1, 2, 2, 0.1, 0.1, false)
	
	velocity = velocity.move_toward(input_dir * slide_speed, slide_accel * delta)
	
	move_and_slide()

func _on_slide_blood_timeout() -> void:
	if _state_machine.get_state_name() != "slide": return
	var new_blood = preload("res://entities/effects/blood/blood.tscn").instantiate()
	new_blood.global_position = global_position 
	GameManager.world.add_child(new_blood)


func _on_damage_manager_dead() -> void:
	get_tree().reload_current_scene()


func _on_weapon_selected(node: Node2D) -> void:
	for w in weapons.get_children():
		w.visible = w == node



