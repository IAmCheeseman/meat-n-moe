extends CharacterBody2D

@onready var sprite := $Sprite
@onready var blood := $Sprite/Blood
@onready var animation := $Animation
@onready var shadow = $Shadow
@onready var health_vignette = $CanvasLayer/Health

@onready var weapons = $Sprite/Weapons
@onready var hook := $Sprite/Weapons/Hook

@onready var roll_timer := $Timers/Roll

@onready var damage_manager := $DamageManager

@export_category("Movement")
@export var speed := 150.0
@export var accel := 300.0
@export var frict := 300.0

@export_subgroup("Roll", "roll")
@export var roll_speed := 300.0
@export var roll_time := 0.3
@export var roll_velocity_reduce := 0.5

@export_subgroup("Hook", "hook")
@export var hook_speed := 500.0

@export_category("Health")
@export var regen_rate := 1.0

@export_category("Blood")
@export var blood_reduce_rate := 0.2

var _s_default = State.new(
	"default",
	Callable(self, "_default_process")
)
var _s_roll = State.new(
	"roll",
	Callable(self, "_roll_process"),
	Callable(self, "_roll_ready"),
	Callable(self, "_roll_end")
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
	shadow.texture = ShadowGenerator.generate(sprite.texture.get_width())
	
	damage_manager.check_functions.append(
		func(amt: float, kb: Vector2):
			var weapon := weapons.get_child(current_weapon)
			var blocked := -kb.dot(get_local_mouse_position()) < 0.25
			return weapon.name != "Shield" or !weapon.visible or blocked
	)

func _physics_process(delta: float) -> void:
	_state_machine.process(delta)
	
	sprite.scale.x = 1 if get_local_mouse_position().x < 0 else -1
	
	damage_manager.health += delta * regen_rate
	damage_manager.health = clamp(damage_manager.health, 0, damage_manager.max_health)
	var percentage_down = 1 - damage_manager.health / damage_manager.max_health
	health_vignette.material.set_shader_uniform("amp", percentage_down)
	
	if velocity != Vector2.ZERO:
		blood.material.set_shader_uniform(
			"amount",
			clamp(blood.material.get_shader_uniform("amount") - blood_reduce_rate * delta, 0.0, 0.8)
		)
		
	blood.offset = sprite.offset

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("roll") and _is_state("default") and _get_input_dir() != Vector2.ZERO:
		_state_machine.change_state(_s_roll)
		get_tree().root.set_input_as_handled()
		return


func _default_process(delta: float) -> void:
	var input_dir := _get_input_dir()
	var movement_delta := accel if input_dir.dot(velocity) > 0 else frict
	
	velocity = velocity.move_toward(input_dir * speed, movement_delta * delta)
	
	move_and_slide()
	
	animation.bob(delta, 5 if velocity == Vector2.ZERO else 15, -1.5, 3)


func _roll_ready() -> void:
	velocity = _get_input_dir() * roll_speed
	roll_timer.start(roll_time)

func _roll_process(delta: float) -> void:
	move_and_slide()
	
	GameManager.camera.shake(1, 4, 4, 0.1, 0.1, false)
	
	animation.roll(delta, roll_timer.time_left / roll_timer.wait_time)

func _roll_end() -> void:
	velocity *= roll_velocity_reduce

func _on_roll_timeout() -> void:
	_state_machine.change_state(_s_default)


func _on_damage_manager_dead() -> void:
	get_tree().reload_current_scene()


func _on_weapon_selected(node: Node2D) -> void:
	current_weapon = node.get_index()
	for w in weapons.get_children():
		w.visible = w == node
