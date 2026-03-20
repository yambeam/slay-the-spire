class_name ToolTip
extends Panel

@onready var description: Label = %Description

func set_text(text: String) -> void:
	description.text = text
	# 等待label更新
	await get_tree().process_frame
	size = description.size + Vector2(20, 20)
