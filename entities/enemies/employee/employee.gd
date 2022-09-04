extends Enemy
class_name Employee

@onready var blood := $Sprite/Blood

@onready var arm := $Sprite/Arm

@onready var aim_timer := $Timers/Aim
@onready var give_up_timer := $Timers/WalkGiveUp

@onready var hey_sfx := $HeySFX
@onready var hurt_sfx := $HurtSFX
@onready var death_sfx := $DieSFX
@onready var shoot_sfx := $ShootSFX

@export var aim_dist := 5.0
@export var corpse_texture := preload("res://assets/entities/employee_corpse.png")

var death_sounds := [
	preload("res://assets/sounds/death_employee_1.wav"),
	preload("res://assets/sounds/death_employee_2.wav"),
]

var hurt_sounds := [
	preload("res://assets/sounds/hurt_employee_1.wav"),
	preload("res://assets/sounds/hurt_employee_2.wav"),
	preload("res://assets/sounds/hurt_employee_3.wav"),
]

var _s_aim := State.new(
	"aim",
	Callable(self, "_aim_process"),
	Callable(self, "_aim_start"),
	Callable(self, "_aim_end")
)

var _continuous_shots := 0


func _ready() -> void:
	arm.hide()
	_assign_shadow()
	blood.material = blood.material.duplicate()

func _process(_delta: float) -> void:
	blood.frame = sprite.frame


func _idle_process(delta: float) -> void:
	var target_dir = Pathfinder.get_astar_path(
		global_position,
		target_position
	)
	if global_position.distance_to(target_position) < aim_dist:
		target_dir = Vector2.ZERO
	
	velocity = velocity.move_toward(
		target_dir,
		accel * delta
	)
	
	if velocity.length() < 10:
		animation_player.play("employee_animations/Idle")
	else:
		animation_player.play("employee_animations/Walk")
	
	velocity = velocity.move_toward(Vector2.ZERO, frict * delta)
	
	move_and_slide()
	
	if _player:
		_state_machine.change_state(_s_walk)


func _walk_start() -> void:
	_new_target_position()
	give_up_timer.start()

func _walk_process(delta: float) -> void:
	animation_player.play("employee_animations/Walk")
	sprite.scale.x = -1 if velocity.x < 0 else 1
	
	var target_dir = Pathfinder.get_astar_path(
		global_position,
		target_position
	)
	
	if target_dir == Vector2.ZERO:
		target_dir = global_position.direction_to(target_position)
	
	velocity = velocity.move_toward(target_dir * speed, accel * delta)
	
	move_and_slide()
	
	if global_position.distance_to(target_position) < aim_dist:
		_state_machine.change_state(_s_aim)


func _on_give_up_time_timeout() -> void:
	if global_position.distance_to(target_position) > aim_dist:
		_new_target_position()
	if _state_machine.get_state_name() == "walk":
		give_up_timer.start()


func _aim_start() -> void:
	aim_timer.start()
	arm.show()
	_continuous_shots += 1

func _aim_process(_delta: float) -> void:
	animation_player.play("employee_animations/Aim")
	
	arm.look_at(_player.global_position)
	
	sprite.scale.x = -1 if _player.global_position.x < global_position.x else 1

func _aim_end() -> void:
	shoot_sfx.play()
	_shoot()
	
	arm.hide()


func _shoot() -> void:
	var new_bullet := preload("res://entities/hitscan-bullet/bullet.tscn").instantiate()
	var dir := global_position.direction_to(_player.global_position)
	
	new_bullet.global_position = global_position + dir * 8
	new_bullet.dir = dir
	new_bullet.shooter = self
	
	GameManager.world.add_child(new_bullet)


func _on_aim_timeout() -> void:
	if randf() > 0.6 or _continuous_shots >= 3:
		_state_machine.change_state(_s_walk)
		_continuous_shots = 0
	else:
		_state_machine.change_state(_s_aim)


func _on_death() -> void:
	var corpse = preload("res://entities/corpse/corpse.tscn").instantiate()
	corpse.global_position = global_position
	corpse.velocity = damage_manager.previous_kb * 150
	call_deferred("add_sibling", corpse)
	await FrameTimer.physics_timer(self).timeout
	corpse.set_sprite(corpse_texture)
	
	death_sfx.stream = death_sounds[death_sounds.size() * randf()]
	death_sfx.play()
	death_sfx.connect("finished", Callable(self, "queue_free"))
	
	hide()
	_state_machine.change_state(null)

func _on_took_damage() -> void:
	hurt_sfx.stream = hurt_sounds[hurt_sounds.size() * randf()]
	hurt_sfx.play()


func _on_found_player() -> void:
	hey_sfx.play()
