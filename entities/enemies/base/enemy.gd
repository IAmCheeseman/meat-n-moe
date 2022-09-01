extends CharacterBody2D
class_name Enemy

@onready var player_detection := $Collisions/PlayerDetection
@onready var collision_checker := $Collisions/CollisionChecker

@onready var sprite := $Sprite
@onready var shadow := $Shadow
@onready var animation_player := $AnimationPlayer

@onready var damage_manager := $DamageManager

@export_category("Movement")
@export var speed := 90.0
@export var accel := 300.0
@export var frict := 300.0

@export var wander_range := 32.0


@warning_ignore(unused_private_class_variable)
var _s_walk := State.new(
	"walk",
	Callable(self, "_walk_process"),
	Callable(self, "_walk_start"),
	Callable(self, "_walk_end")
)
var _s_idle := State.new(
	"idle",
	Callable(self, "_idle_process"),
	Callable(self, "_idle_start")
)
var _state_machine := StateMachine.new(_s_idle)

var _player: CharacterBody2D

var target_position := Vector2.ZERO

var callouts := []


func recieve_player_callout(enemy: Enemy, player: CharacterBody2D, callout_id: int) -> void:
	if global_position.distance_to(enemy.global_position) < 48 and !callout_id in callouts:
		target_position = player.global_position
		callouts.append(callout_id)
		get_tree().call_group("enemy", "recieve_player_callout", self, player)

func _new_target_position() -> void:
	var base_position = global_position
	if _player:
		base_position = _player.global_position
	target_position = base_position + Vector2.RIGHT.rotated(TAU * randf()) * wander_range * randf()
	
	collision_checker.global_position = target_position
	await get_tree().physics_frame
	if collision_checker.get_overlapping_bodies().size() > 0:
		_new_target_position()


func _assign_shadow() -> void:
	shadow.texture = ShadowGenerator.generate(sprite.texture.get_width() / sprite.hframes)

func _physics_process(delta: float) -> void:
	if !_player:
		_player = player_detection.get_player()
		if _player:
			get_tree().call_group("enemy", "recieve_player_callout", self, _player, GameManager.enemy_callouts)
			GameManager.enemy_callouts += 1
	_state_machine.process(delta)


func _idle_start() -> void:
	target_position = global_position

func _idle_process(_delta: float) -> void:
	pass


func _walk_start() -> void:
	pass

func _walk_process(_delta: float) -> void:
	pass

func _walk_end() -> void:
	pass

