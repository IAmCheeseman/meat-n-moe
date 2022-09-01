extends Node2D

@onready var player = $"../../../"

@onready var chain: Line2D = $Chain
@onready var hook_sprite := $HookSprite

@onready var rc := $RayCast

@export var hook_speed := 500.0

var _s_idle := State.new(
	"idle",
	Callable(self, "_idle_process")
)
var _s_hook_in := State.new(
	"hook_in",
	Callable(self, "_hook_in_process"),
	Callable(self, "_hook_in_start")
)
var _s_hook_out := State.new(
	"hook_out",
	Callable(self, "_hook_out_process")
)
var state_machine := StateMachine.new(_s_idle)

var _end_position := Vector2.ZERO
var _prev_posititon := Vector2.ZERO
var _hook_dir := Vector2.ZERO
var _going_out := true

signal hook_hit(end_position: Vector2)


func _generate_chain() -> void:
	chain.clear_points()
	chain.add_point(Vector2.ZERO)
	chain.add_point(to_local(_end_position))
	
	hook_sprite.position = to_local(_prev_posititon)
	hook_sprite.rotation = _hook_dir.angle()
	
	rc.position = to_local(_prev_posititon)
	rc.target_position = _hook_dir * 8


func _physics_process(delta: float) -> void:
	state_machine.process(delta)


func _idle_process(_delta: float) -> void:
	if Input.is_action_just_pressed("secondary_move"):
		state_machine.change_state(_s_hook_in)


func _hook_in_start() -> void:
	show()
	
	_hook_dir = global_position.direction_to(get_global_mouse_position())
	_end_position = global_position + _hook_dir * 5
	_going_out = true
	
	_prev_posititon = global_position + _hook_dir * 5
	
	rc.target_position = _hook_dir * 5
	
	_generate_chain()

func _hook_in_process(delta: float) -> void:
	_prev_posititon = _end_position
	if _going_out:
		_end_position += _hook_dir * hook_speed * delta
	_generate_chain()
	
	if rc.is_colliding():
		_end_position = rc.get_collision_point()
		emit_signal("hook_hit", _end_position)
		_going_out = false
