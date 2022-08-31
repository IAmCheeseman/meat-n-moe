extends Node
class_name DamageManager

@onready var parent = get_parent()

@export_node_path(Area2D) var hurtbox_path
@onready var hurtbox := get_node(hurtbox_path)
@export_node_path(Sprite2D) var blood_path
@export var max_health := 3.0
@export var defense := 1.0
@export var kb_multiplier := 150.0
@export var blood_splatter := true
@export var is_enemy := true

var blood: Sprite2D

var health := 0.0

var previous_kb: Vector2

signal took_damage
signal dead


func _ready() -> void:
	health = max_health
	hurtbox.connect("took_damage", Callable(self, "take_damage"))
	
	if blood_path:
		blood = get_node(blood_path)


func take_damage(amt: float, kb: Vector2) -> void:
	health -= amt / defense
	parent.velocity += kb * kb_multiplier
	
	previous_kb = kb
	
	emit_signal("took_damage")
	
	if blood_splatter:
		for i in randi_range(3, 8):
			var new_blood = preload("res://entities/effects/blood/blood.tscn").instantiate()
			var dir = kb.rotated(randf_range(-PI / 4, PI / 4))
			new_blood.global_position = parent.global_position + dir * randf_range(0, 32)
			GameManager.world.add_child(new_blood)
	
	if is_instance_valid(blood):
		blood.material.set_shader_uniform("amount", 1 - health / max_health)
	
	if health <= 0:
		emit_signal("dead")
	
	get_tree().call_group("player", "add_blood", parent)
