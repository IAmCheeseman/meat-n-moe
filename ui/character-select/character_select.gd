extends Control

@onready var moe_button = %SelectMoe
@onready var meat_button = %SelectMeat

@export_node_path(Marker2D) var player_start_path
@onready var player_start: Marker2D = get_node(player_start_path)

func _ready() -> void:
	show()
	moe_button.grab_focus()

func spawn_player(player_obj: PackedScene) -> void:
	var player = player_obj.instantiate()
	player.global_position = player_start.global_position
	player_start.add_sibling(player)
	queue_free()


func _on_moe_pressed() -> void:
	spawn_player(preload("res://entities/player/moe/player.tscn"))


func _on_meat_pressed() -> void:
	spawn_player(preload("res://entities/player/meat/player.tscn"))
