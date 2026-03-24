class_name IntentUI
extends Control

@onready var icon: Sprite2D = $Icon
@onready var value: RichTextLabel = $Value

var sub_intent: SubIntent

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	hide()

func update_display(sub_intent_: SubIntent) -> void:
	sub_intent = sub_intent_
	icon.texture = sub_intent.icon
	value.text = sub_intent.get_text()
	
func _on_mouse_entered():
	if sub_intent:
		Events.tooltip_show_request.emit(self)

func _on_mouse_exited():
	if sub_intent:
		Events.tooltip_hide_request.emit()

func show_keyword_tooltip() -> void:
	if sub_intent:
		KeywordTooltip.add_keyword(sub_intent.get_intent_name(), sub_intent.get_intent_description())
		KeywordTooltip.keyword_tooltip.global_position = global_position + Vector2(size.x * 2, 0)
