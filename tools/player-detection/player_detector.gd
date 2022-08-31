extends Area2D

func get_player() -> CharacterBody2D:
	for b in get_overlapping_bodies():
		if b.is_in_group("player"):
			return b
	return null
