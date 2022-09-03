extends Camera2D
class_name CustomCamera

@export_category("Camera Look")
@export var weight := 0.125

var priority := 0
var shake_dir := Vector2.ZERO
var shake_range := [0., 0.]
var shake_time := 0.
var shake_freq := 0.
var shake_reduce := false

var jump_timer: Timer
var shake_timer: Timer

@onready var parent: Node2D = get_parent()

func _set_up_timer() -> Timer:
	var new_timer = Timer.new()
	add_child(new_timer)
	
	return new_timer


func _ready() -> void:
	GameManager.camera = self
	
	jump_timer = _set_up_timer()
	jump_timer.connect("timeout", Callable(self, "jump"))
	shake_timer = _set_up_timer()
	shake_timer.connect("timeout", Callable(self, "reset"))
	
	reset()


func _process(delta: float) -> void:
	var mouse_pos = parent.get_local_mouse_position()
	position = mouse_pos * weight
	
	offset = offset.move_toward(Vector2.ZERO, 100 * delta)


func reset() -> void:
	priority = 0
	shake_dir = Vector2.ZERO
	shake_range = [0., 0.]
	shake_time = 0
	shake_freq = 0
	shake_reduce = false


func shake(pri: int, shake_min: float, shake_max: float, time: float, freq: float, reduce: bool, set_dir:=Vector2.ZERO) -> void:
	if pri < priority: return
	priority = pri
	shake_range = [shake_min, shake_max]
	shake_time = clamp(time, 0.01, INF)
	shake_freq = freq
	shake_reduce = reduce
	shake_dir = set_dir

	shake_timer.start(shake_time)
	jump_timer.start(shake_freq)

	jump()

func jump() -> void:
	var dist = randf_range(shake_range[0], shake_range[1])
	if shake_reduce: dist *= shake_timer.time_left / shake_timer.wait_time
	var dir = Vector2.RIGHT.rotated(randf_range(0, PI * 2)) if shake_dir == Vector2.ZERO else shake_dir

	offset = dir * dist
