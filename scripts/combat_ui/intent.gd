class_name IntentUI
extends Control

@onready var icon: Sprite2D = $Icon
@onready var value: RichTextLabel = $Value

func _ready() -> void:
	hide()

func update_display(icon_: Texture, value_: String) -> void:
	icon.texture = icon_
	value.text = value_
