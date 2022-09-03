extends Node2D
@tool

@onready var sprite = $Sprite

@export_category("Info")
@export var boss := false
@export var level_name := "[Name]"
@export_multiline var level_desc := "[Description]"
@export_file("*.tscn") var level := "res://world/world.tscn"
@export var level_texture := preload("res://assets/ui/building_level.png") :
	set(value):
		level_texture = value
		if Engine.is_editor_hint():
			sprite.texture = level_texture

@onready var focused = false :
	set(value):
		focused = value
		sprite.material.set_shader_uniform("width", int(focused))
		z_index = int(!focused)
		if focused: emit_signal("selected", self)
	get:
		return focused

signal selected(node: Node2D)


func _ready() -> void:
	focused = get_index() == 0
	sprite.material = sprite.material.duplicate()
	sprite.texture = level_texture
	if focused:
		sprite.material.set_shader_uniform("width", int(focused))
		emit_signal("selected", self)


func _unhandled_input(event: InputEvent) -> void:
	if focused:
		if event.is_action_pressed("ui_accept"):
			get_tree().change_scene(level)
		
		# Moving focus
		if event.is_action_pressed("ui_up") and get_index() != get_parent().get_child_count() - 1:
			focused = false
			get_parent().get_child(get_index() + 1).focused = true
		if event.is_action_pressed("ui_down") and get_index() != 0:
			focused = false
			get_parent().get_child(get_index() - 1).focused = true
		
		get_tree().root.set_input_as_handled()
