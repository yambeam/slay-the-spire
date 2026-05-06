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
	var intent_icon: Texture2D
	value.text = sub_intent.get_text()
	match sub_intent.type:
		SubIntent.Type.ATTACK:
			sub_intent = sub_intent as AttackSubIntent
			var total_damage = sub_intent.get_total_damage()
			if (total_damage < 5):
				intent_icon = ItemPool.intent_dict["attack1"]
			elif (total_damage < 10):
				intent_icon = ItemPool.intent_dict["attack2"]
			elif (total_damage < 20 ):
				intent_icon = ItemPool.intent_dict["attack3"]
			elif (total_damage < 30):
				intent_icon = ItemPool.intent_dict["attack4"]
			else:
				intent_icon = ItemPool.intent_dict["attack5"]
		SubIntent.Type.BUFF:
			intent_icon = ItemPool.intent_dict["buff"]
		SubIntent.Type.CARD_DEBUFF:
			intent_icon = ItemPool.intent_dict["card_debuff"]
		SubIntent.Type.DEFFEND:
			intent_icon = ItemPool.intent_dict["deffend"]
		SubIntent.Type.DEBUFF:
			intent_icon = ItemPool.intent_dict["debuff"]
		SubIntent.Type.ESCAPE:
			intent_icon = ItemPool.intent_dict["escape"]
		SubIntent.Type.HEAL:
			intent_icon = ItemPool.intent_dict["heal"]
		SubIntent.Type.SLEEP:
			intent_icon = ItemPool.intent_dict["sleep"]
		SubIntent.Type.STATUS:
			intent_icon = ItemPool.intent_dict["status"]
		SubIntent.Type.STUN:
			intent_icon = ItemPool.intent_dict["stun"]
		SubIntent.Type.SUMMON:
			intent_icon = ItemPool.intent_dict["summon"]
		SubIntent.Type.SUMMON:
			intent_icon = ItemPool.intent_dict["unknown"]
		
	icon.texture = intent_icon
func _on_mouse_entered():
	if sub_intent:
		Events.tooltip_show_request.emit(self, show_keyword_tooltip)

func _on_mouse_exited():
	if sub_intent:
		Events.tooltip_hide_request.emit()

func show_keyword_tooltip() -> void:
	if sub_intent:
		KeywordTooltip.add_keyword(sub_intent.get_intent_name(), sub_intent.get_intent_description())
		KeywordTooltip.keyword_tooltip.global_position = global_position + Vector2(size.x * 2, 0)
