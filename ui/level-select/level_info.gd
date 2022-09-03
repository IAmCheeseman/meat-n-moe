extends Control

@onready var title: Label = %LevelSelectTitle
@onready var desc := %LevelSelectDesc

func set_text(node: Node2D) -> void:
	title.text = ("#%s - " % node.get_index()) + node.level_name
	if node.boss:
		title.label_settings.font_color = Color.RED
	else:
		title.label_settings.font_color = Color.WHITE
	desc.text = node.level_desc
