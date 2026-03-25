class_name ToolTipEntry
extends Panel

@onready var title: RichTextLabel = %title
@onready var description: RichTextLabel = %description

func setup(title_: String, desc: String) -> void:
	title.text = title_
	description.text = desc
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.custom_minimum_size.x = 200
