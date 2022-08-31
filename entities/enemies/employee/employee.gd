extends Enemy

@onready var blood := $Sprite/Blood

@onready var arm := $Sprite/Arm

@onready var aim_timer := $Timers/Aim
@onready var give_up_timer := $Timers/WalkGiveUp

@export var aim_dist := 5.0

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

func _process(_delta: float) -> void:
	blood.frame = sprite.frame


func _idle_process(delta: float) -> void:
	animation_player.play("employee_animations/Idle")
	
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
	var new_bullet := preload("res://entities/hitscan-bullet/bullet.tscn").instantiate()
	var dir := global_position.direction_to(_player.global_position)
	
	new_bullet.global_position = global_position + dir * 8
	new_bullet.dir = dir
	new_bullet.shooter = self
	
	GameManager.world.add_child(new_bullet)
	
	arm.hide()


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
	GameManager.world.add_child(corpse)
	corpse.set_sprite(preload("res://assets/entities/employee_corpse.png"))
	
	queue_free()
